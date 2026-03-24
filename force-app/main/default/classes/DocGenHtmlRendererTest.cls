@IsTest
private class DocGenHtmlRendererTest {

    @IsTest
    static void testBasicParagraph() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:t>Hello World</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);

            System.assert(html.contains('<body>'), 'Should contain body tag');
            System.assert(html.contains('Hello World'), 'Should contain text');
            System.assert(html.contains('<p>'), 'Should contain paragraph tag');
        }
    }

    @IsTest
    static void testBoldItalicUnderline() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:rPr><w:b/><w:i/><w:u w:val="single"/></w:rPr><w:t>Styled</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);

            System.assert(html.contains('<b>'), 'Should contain bold');
            System.assert(html.contains('<i>'), 'Should contain italic');
            System.assert(html.contains('<u>'), 'Should contain underline');
            System.assert(html.contains('Styled'), 'Should contain text');
        }
    }

    @IsTest
    static void testParagraphAlignment() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:t>Centered</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);

            System.assert(html.contains('text-align:center'), 'Should have center alignment');
        }
    }

    @IsTest
    static void testFontSizeAndColor() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:rPr><w:sz w:val="28"/><w:color w:val="FF0000"/></w:rPr><w:t>Big Red</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);

            System.assert(html.contains('font-size:14'), 'Should have 14pt font (28/2)');
            System.assert(html.contains('#FF0000'), 'Should have red color');
        }
    }

    @IsTest
    static void testTable() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:tbl>' +
                '<w:tblPr><w:tblBorders><w:top w:val="single"/></w:tblBorders></w:tblPr>' +
                '<w:tr>' +
                '<w:tc><w:p><w:r><w:t>Cell 1</w:t></w:r></w:p></w:tc>' +
                '<w:tc><w:p><w:r><w:t>Cell 2</w:t></w:r></w:p></w:tc>' +
                '</w:tr>' +
                '</w:tbl>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);

            System.assert(html.contains('<table'), 'Should contain table');
            System.assert(html.contains('<tr>'), 'Should contain row');
            System.assert(html.contains('<td'), 'Should contain cell');
            System.assert(html.contains('Cell 1'), 'Should contain cell text');
            System.assert(html.contains('Cell 2'), 'Should contain cell text');
        }
    }

    @IsTest
    static void testTableCellShading() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:tbl><w:tblPr></w:tblPr>' +
                '<w:tr><w:tc><w:tcPr><w:shd w:val="clear" w:fill="E2EFDA"/></w:tcPr>' +
                '<w:p><w:r><w:t>Shaded</w:t></w:r></w:p></w:tc></w:tr>' +
                '</w:tbl>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);

            System.assert(html.contains('#E2EFDA'), 'Should contain shading color');
        }
    }

    @IsTest
    static void testLineBreak() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:t>Before</w:t></w:r><w:r><w:br/></w:r><w:r><w:t>After</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);

            System.assert(html.contains('<br/>'), 'Should contain line break');
            System.assert(html.contains('Before'), 'Should contain text before break');
            System.assert(html.contains('After'), 'Should contain text after break');
        }
    }

    @IsTest
    static void testImageWithBase64() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String fakeBase64 = EncodingUtil.base64Encode(Blob.valueOf('fake image data'));
            Map<String, String> images = new Map<String, String>{
                'rIdImg1' => fakeBase64
            };

            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:drawing>' +
                '<wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">' +
                '<wp:extent cx="1905000" cy="952500"/>' +
                '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' +
                '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:blipFill><a:blip r:embed="rIdImg1" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/></pic:blipFill>' +
                '</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml, images);

            System.assert(html.contains('<img'), 'Should contain image tag');
            System.assert(html.contains('data:image/png;base64,'), 'Should contain base64 data URI');
        }
    }

    @IsTest
    static void testEmptyDocument() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String html = DocGenHtmlRenderer.convertToHtml('');
            System.assert(html.contains('<body>'), 'Should return valid HTML for empty input');
            System.assert(html.contains('</body>'), 'Should close body tag');
        }
    }

    @IsTest
    static void testNullDocument() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String html = DocGenHtmlRenderer.convertToHtml(null);
            System.assert(html.contains('<body>'), 'Should return valid HTML for null input');
        }
    }

    @IsTest
    static void testNoImagesOverload() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body><w:p><w:r><w:t>Test</w:t></w:r></w:p></w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('Test'), 'Should handle no-image overload');
        }
    }

    @IsTest
    static void testMultipleRuns() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p>' +
                '<w:r><w:t>Hello </w:t></w:r>' +
                '<w:r><w:rPr><w:b/></w:rPr><w:t>World</w:t></w:r>' +
                '</w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);

            System.assert(html.contains('Hello '), 'Should contain first run text');
            System.assert(html.contains('<b>'), 'Should contain bold tag');
            System.assert(html.contains('World'), 'Should contain second run text');
        }
    }

    @IsTest
    static void testSpacingAndIndent() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:pPr><w:spacing w:before="120" w:after="240"/><w:ind w:left="720"/></w:pPr>' +
                '<w:r><w:t>Indented</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);

            System.assert(html.contains('margin-top:'), 'Should have top margin');
            System.assert(html.contains('margin-bottom:'), 'Should have bottom margin');
            System.assert(html.contains('margin-left:'), 'Should have left indent');
        }
    }

    // =========================================================================
    // Additional coverage tests
    // =========================================================================

    @IsTest
    static void testNullImagesMap() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Exercises the images == null guard in convertToHtml
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body><w:p><w:r><w:t>Text</w:t></w:r></w:p></w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml, null);
            System.assert(html.contains('Text'), 'Should handle null images map');
        }
    }

    @IsTest
    static void testParagraphAlignmentRightAndJustify() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers right/end and both/distribute alignment branches
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:t>Right</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:jc w:val="end"/></w:pPr><w:r><w:t>End</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:jc w:val="both"/></w:pPr><w:r><w:t>Justify</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:jc w:val="distribute"/></w:pPr><w:r><w:t>Distribute</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('text-align:right'), 'Should have right alignment');
            System.assert(html.contains('text-align:justify'), 'Should have justify alignment');
        }
    }

    @IsTest
    static void testIndentRightAndFirstLine() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers w:ind w:right and w:firstLine branches
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:pPr><w:ind w:left="360" w:right="360" w:firstLine="720"/></w:pPr>' +
                '<w:r><w:t>Indented</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('margin-right:'), 'Should have right indent');
            System.assert(html.contains('text-indent:'), 'Should have first line indent');
        }
    }

    @IsTest
    static void testStrikethrough() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers w:strike branch
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:rPr><w:strike/></w:rPr><w:t>Struck</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('<s>'), 'Should contain strikethrough');
            System.assert(html.contains('Struck'), 'Should contain text');
        }
    }

    @IsTest
    static void testFontFamilyAndHighlight() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers w:rFonts (hAnsi fallback) and w:highlight branches
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:rPr><w:rFonts w:hAnsi="Times New Roman"/><w:highlight w:val="yellow"/></w:rPr><w:t>Highlighted</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('Times New Roman'), 'Should contain font family from hAnsi');
            System.assert(html.contains('background-color:yellow'), 'Should contain highlight');
        }
    }

    @IsTest
    static void testColorAuto() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers the color == 'auto' skip branch
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:rPr><w:color w:val="auto"/></w:rPr><w:t>Auto</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(!html.contains('color:#auto'), 'Should not include auto color');
            System.assert(html.contains('Auto'), 'Should contain text');
        }
    }

    @IsTest
    static void testTableWidthPercent() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers tblW with type=pct branch
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:tbl><w:tblPr><w:tblW w:w="5000" w:type="pct"/></w:tblPr>' +
                '<w:tr><w:tc><w:p><w:r><w:t>Cell</w:t></w:r></w:p></w:tc></w:tr>' +
                '</w:tbl>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('width:') && html.contains('%'), 'Should have percentage width from pct type');
        }
    }

    @IsTest
    static void testTableCellWidthTypes() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers tcW with pct type and dxa type branches
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:tbl><w:tblPr><w:tblBorders><w:top w:val="single"/></w:tblBorders></w:tblPr>' +
                '<w:tr>' +
                '<w:tc><w:tcPr><w:tcW w:w="2500" w:type="pct"/></w:tcPr><w:p><w:r><w:t>Pct</w:t></w:r></w:p></w:tc>' +
                '<w:tc><w:tcPr><w:tcW w:w="2880" w:type="dxa"/></w:tcPr><w:p><w:r><w:t>Dxa</w:t></w:r></w:p></w:tc>' +
                '</w:tr>' +
                '</w:tbl>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('border:1px solid #000'), 'Should have cell borders');
            System.assert(html.contains('Pct'), 'Should contain pct cell text');
            System.assert(html.contains('Dxa'), 'Should contain dxa cell text');
        }
    }

    @IsTest
    static void testCellVerticalAlignment() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers w:vAlign branch
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:tbl><w:tblPr></w:tblPr>' +
                '<w:tr><w:tc><w:tcPr><w:vAlign w:val="center"/></w:tcPr>' +
                '<w:p><w:r><w:t>Centered</w:t></w:r></w:p></w:tc></w:tr>' +
                '</w:tbl>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('vertical-align:center'), 'Should have vertical alignment');
        }
    }

    @IsTest
    static void testImageJpegDetection() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers JPEG detection branch (base64 starting with /9j/)
            String jpegBase64 = '/9j/4AAQSkZJRgABAQEASABIAAD';
            Map<String, String> images = new Map<String, String>{ 'rIdImg1' => jpegBase64 };

            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:drawing>' +
                '<wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">' +
                '<wp:extent cx="952500" cy="476250"/>' +
                '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' +
                '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:blipFill><a:blip r:embed="rIdImg1" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/></pic:blipFill>' +
                '</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml, images);
            System.assert(html.contains('image/jpeg'), 'Should detect JPEG MIME type');
        }
    }

    @IsTest
    static void testImageMissingRelId() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers relId == null return '' branch
            Map<String, String> images = new Map<String, String>();

            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:drawing>' +
                '<wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">' +
                '<wp:extent cx="952500" cy="476250"/>' +
                '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' +
                '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:blipFill></pic:blipFill>' +
                '</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml, images);
            System.assert(!html.contains('<img'), 'Should not produce img tag when no blip embed');
        }
    }

    @IsTest
    static void testImageMissingBase64() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers base64 == null return '' branch (relId exists but not in images map)
            Map<String, String> images = new Map<String, String>();

            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:drawing>' +
                '<wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">' +
                '<wp:extent cx="952500" cy="476250"/>' +
                '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' +
                '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:blipFill><a:blip r:embed="rIdMissing" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/></pic:blipFill>' +
                '</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml, images);
            System.assert(!html.contains('<img'), 'Should not produce img tag when base64 not in map');
        }
    }

    @IsTest
    static void testImageDimensionFallbackFromAExt() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers the fallback to a:ext for cx/cy when wp:extent is absent
            String fakeBase64 = EncodingUtil.base64Encode(Blob.valueOf('fake image'));
            Map<String, String> images = new Map<String, String>{ 'rIdImg2' => fakeBase64 };

            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:drawing>' +
                '<wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">' +
                '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' +
                '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:blipFill><a:blip r:embed="rIdImg2" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/></pic:blipFill>' +
                '<pic:spPr><a:xfrm><a:ext cx="1905000" cy="952500"/></a:xfrm></pic:spPr>' +
                '</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml, images);
            System.assert(html.contains('<img'), 'Should contain image tag');
        }
    }

    @IsTest
    static void testEmptyParagraphRendersNbsp() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers blank content branch in processParagraph
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:pPr><w:jc w:val="center"/></w:pPr></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('&nbsp;'), 'Empty paragraph should render nbsp');
        }
    }

    @IsTest
    static void testSelfClosingParagraph() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers <w:p/> self-closing paragraph handling
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p/>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('<body>'), 'Should produce valid HTML');
        }
    }

    @IsTest
    static void testSelfClosingTextElement() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers self-closing <w:t/> skip in extractTextContent
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:t/><w:t>After</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('After'), 'Should skip self-closing w:t and continue');
        }
    }

    @IsTest
    static void testNoBodyTag() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers extractBodyContent when no w:body tag exists
            String xml = '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:p><w:r><w:t>NoBody</w:t></w:r></w:p></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('<body>'), 'Should still produce valid HTML');
        }
    }

    @IsTest
    static void testBodyWithoutClosingTag() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers extractBodyContent when no </w:body> close tag
            String xml = '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body><w:p><w:r><w:t>Open</w:t></w:r></w:p></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('Open'), 'Should handle missing close body tag');
        }
    }

    @IsTest
    static void testDrawingOutsideRun() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers standalone w:drawing outside of w:r in processRuns
            String fakeBase64 = EncodingUtil.base64Encode(Blob.valueOf('fake'));
            Map<String, String> images = new Map<String, String>{ 'rIdStandalone' => fakeBase64 };

            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:drawing>' +
                '<wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">' +
                '<wp:extent cx="952500" cy="476250"/>' +
                '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' +
                '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:blipFill><a:blip r:embed="rIdStandalone" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/></pic:blipFill>' +
                '</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml, images);
            System.assert(html.contains('<img'), 'Should process drawing outside of w:r');
        }
    }

    @IsTest
    static void testSectPrStripping() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers sectPr stripping from body content
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:t>Before</w:t></w:r></w:p>' +
                '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/></w:sectPr>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('Before'), 'Should contain text');
            System.assert(!html.contains('pgSz'), 'Should strip section properties');
        }
    }

    @IsTest
    static void testRunWithAttributeStart() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers <w:r ...> with attributes (runStart2 branch)
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r w:rsidR="00112233"><w:t>WithAttr</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('WithAttr'), 'Should handle runs with attributes');
        }
    }

    @IsTest
    static void testParagraphWithAttributes() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers <w:p ...> with attributes
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p w:rsidR="00112233"><w:r><w:t>ParaAttr</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('ParaAttr'), 'Should handle paragraphs with attributes');
        }
    }

    @IsTest
    static void testExtractElementSelfClosing() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers self-closing element in extractElement
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:pPr><w:jc w:val="left"/></w:pPr><w:r><w:t>Left</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('Left'), 'Should handle self-closing elements in pPr');
        }
    }

    @IsTest
    static void testFontWithAsciiAttr() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers w:rFonts w:ascii path (primary path)
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:p><w:r><w:rPr><w:rFonts w:ascii="Courier New"/></w:rPr><w:t>Mono</w:t></w:r></w:p>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(html.contains('Courier New'), 'Should contain ascii font');
        }
    }

    @IsTest
    static void testCellShadingAutoFill() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            // Covers fill == 'auto' skip branch in cell shading
            String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
                '<w:body>' +
                '<w:tbl><w:tblPr></w:tblPr>' +
                '<w:tr><w:tc><w:tcPr><w:shd w:val="clear" w:fill="auto"/></w:tcPr>' +
                '<w:p><w:r><w:t>AutoFill</w:t></w:r></w:p></w:tc></w:tr>' +
                '</w:tbl>' +
                '</w:body></w:document>';

            String html = DocGenHtmlRenderer.convertToHtml(xml);
            System.assert(!html.contains('background-color:#auto'), 'Should not include auto fill');
            System.assert(html.contains('AutoFill'), 'Should contain text');
        }
    }
}
