# How we beat the 6MB heap limit: Free native document gen + e-signatures, no middleware, no paid tools

---

**TL;DR:** We built a free, open-source, 100% native Salesforce document generation platform that produces signed PDFs with 20+ embedded images and 500+ child record rows — all within Apex governor limits. No external APIs. No callouts. No paid tools. Here's how.

## The Problem

If you've ever tried to generate documents with images server-side in Apex, you know the pain. The synchronous heap limit is 6MB. The async limit is 12MB. A single 1MB image as a base64 string eats 1.3MB of heap. Add a DOCX template (ZIP compressed), decompress it, modify XML, recompress it, and you're out of memory before you've even started on the PDF.

Every paid tool on AppExchange solves this by punting the work to an external API. Callouts, middleware, per-user licensing. The conventional wisdom is: "you can't do native document gen with images at scale in Apex."

We disagreed.

## What We Built

**DocGen** — a completely free, Apache 2.0 licensed document generation platform:

- DOCX, PPTX, and PDF output from any Salesforce record
- Merge fields, child record loops, conditional sections, date formatting
- Image injection from ContentVersion files and Rich Text fields
- Multi-signer electronic signatures with branded emails and audit trails
- Bulk generation across hundreds of records
- Flow integration (invocable actions)
- Zero external dependencies. Zero callouts. Zero npm packages on the server side.

## The Engineering (Here's Where It Gets Fun)

### 1. Pre-Decomposed Templates

The naive approach to DOCX generation: base64-decode the template file, decompress the ZIP, find `document.xml`, do your merge, recompress, done. That's 3-4MB of heap just for a small template.

Our approach: when an admin saves a template version, we deconstruct the DOCX ZIP immediately. Every XML part (`document.xml`, `_rels/document.xml.rels`, headers, footers) and every embedded image gets extracted and stored as an individual ContentVersion record.

At generation time, we never touch the ZIP. We load the raw XML string, do our merge (string substitution, loop expansion, conditional pruning), and go straight to PDF. The ZIP file sits there unused. **~75% heap reduction** on the template processing step alone.

### 2. Zero-Heap Image Rendering

This is the one that changed everything.

For PDF output, when we hit an image merge tag like `{%Description:600x400}`, we don't load the image blob. We query only the ContentVersion ID and file extension — two tiny strings. Then we build a relative URL:

```
/sfc/servlet.shepherd/version/download/{contentVersionId}
```

We inject that URL into an `<img>` tag in the HTML. When `Blob.toPdf()` runs (with the Spring '26 Release Update), the PDF rendering engine resolves the URL server-side and embeds the image.

The image never enters Apex heap. A 1.3MB PNG that would normally cost 1.7MB of heap costs exactly zero. You can have 20 images in a document and the heap usage is the same as having zero images.

But here's the catch — relative URLs only work for `Blob.toPdf()`. They don't work in a browser. Guest users on the signing page need to see a document preview with images, but they have no Salesforce session. So we built a dual-URL strategy:

- **PDF rendering:** Relative ContentVersion URLs (`/sfc/servlet.shepherd/version/download/{cvId}`) — resolved server-side by the PDF engine
- **Browser preview:** Absolute ContentDistribution download URLs (`https://domain.file.force.com/sfc/dist/version/download/...`) — public, no auth required, created at request time

When the admin creates a signature request, we generate a `ContentDistribution` for each image, grab the `ContentDownloadUrl` (not the `DistributionPublicUrl` — that's the viewer page, not the raw image), and render the preview HTML with those public URLs. The guest user's browser loads them directly.

**Result:** PDFs with up to 30MB of total image data, generated within the 6MB synchronous heap limit. And guest users see a pixel-perfect preview with all images rendered, despite having zero Salesforce access.

### 3. Template-Based Signatures (v1.4.0 — The New Stuff)

The old signature flow was brutal on resources:

1. Generate a DOCX per record (ZIP decompress + merge + recompress)
2. Send for signatures
3. Stamp signature images into the DOCX (decompress again, modify XML, add images to ZIP, recompress)
4. Convert stamped DOCX to PDF (decompress AGAIN, extract XML, convert to HTML, render)

That's three full ZIP decompress/recompress cycles. For a document with images, you'd blow the heap limit before step 3.

The new flow:

1. Admin picks a DocGen template + record, sends for signatures
2. Signers sign on a public VF page
3. A single Queueable: load pre-decomposed XML, merge with record data, stamp signatures as DrawingML directly into the XML string (pure string operations — no ZIP), render PDF via `Blob.toPdf()` with URL-referenced images

One transaction. Zero ZIP operations. Zero image blobs in heap. The signatures are just DrawingML XML fragments inserted via `String.replace()`.

### 4. Content Sharing Workarounds

Guest users on the signing page can't query ContentVersion records (Salesforce's content sharing model). Even `WITH SYSTEM_MODE` doesn't bypass it for Content objects.

Our solution: when the admin creates the signature request, we pre-compute everything the guest user and Automated Process user will need:

- Preview HTML with public ContentDistribution download URLs (guest browser can load them without auth)
- Image map cached as JSON on the request record (Automated Process user reads it instead of querying template CVs)

The signing page loads the preview from a regular SObject field query — no Content queries needed.

## Stress Test Results

On a scratch org with the Spring '26 Release Update:

- **Template:** Account header image + 500 contact rows (20 with unique 1.3MB images) + Opportunity data + Buyer/Seller signature placeholders
- **Total image data:** ~27MB across 21 unique images
- **Output:** Signed PDF with all images rendered, both signatures stamped, full audit trail
- **Result:** Generated successfully within governor limits

## The Stack

- **Apex:** Merge engine, HTML renderer, signature stamping, ZIP writer
- **Blob.toPdf():** Native PDF rendering (Spring '26 Release Update required)
- **LWC:** Template manager, document generator, signature sender
- **Visualforce:** Guest user signing page
- **Platform Events + Queueable:** Async signature PDF generation
- **Pure JS:** Client-side DOCX ZIP assembly (zero npm dependencies)

## Get It

It's free. Apache 2.0 license.

- **GitHub:** https://github.com/DaveMoudy/SalesforceDocGen
- **Install in Production:** https://login.salesforce.com/packaging/installPackage.apexp?p0=04tdL000000RdlFQAS
- **Install in Sandbox:** https://test.salesforce.com/packaging/installPackage.apexp?p0=04tdL000000RdlFQAS

```bash
sf package install --package 04tdL000000RdlFQAS --wait 10 --installation-key-bypass
```

After install, assign the **DocGen Admin** permission set and enable the Spring '26 Release Update for `Blob.toPdf()`.

Happy to answer any questions about the architecture, governor limit strategies, or Salesforce PDF rendering quirks. This has been a wild ride.
