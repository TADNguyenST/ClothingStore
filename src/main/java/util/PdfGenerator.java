package util;

import DTO.PurchaseOrderHeaderDTO;
import DTO.PurchaseOrderItemDTO;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.List;

public class PdfGenerator {

    // THAY ĐỔI ĐƯỜNG DẪN NÀY cho đúng với vị trí file font của bạn
    // Ví dụ nếu bạn tạo thư mục resources/fonts trong project
    public static void generateReceiptPdf(OutputStream outputStream, PurchaseOrderHeaderDTO po, List<PurchaseOrderItemDTO> items) throws IOException {

        PdfWriter writer = new PdfWriter(outputStream);
        PdfDocument pdf = new PdfDocument(writer);
        Document document = new Document(pdf, PageSize.A4);
        document.setMargins(30, 30, 30, 30);
        InputStream fontStream = PdfGenerator.class.getClassLoader().getResourceAsStream("fonts/times.ttf");
        if (fontStream == null) {
            throw new IOException("LỖI: Không tìm thấy file font tại 'resources/fonts/times.ttf'. Hãy kiểm tra lại vị trí file.");
        }
        java.io.ByteArrayOutputStream buffer = new java.io.ByteArrayOutputStream();
        int nRead;
        byte[] data = new byte[1024];
        while ((nRead = fontStream.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, nRead);
        }
        buffer.flush();
        byte[] fontBytes = buffer.toByteArray();
        // Tạo font tiếng Việt từ đường dẫn tương đối trong project
        PdfFont font = PdfFontFactory.createFont(fontBytes, PdfFontFactory.EmbeddingStrategy.PREFER_EMBEDDED);
        document.setFont(font);

        // --- Phần Header ---
        document.add(new Paragraph("Đơn vị: Clothing Store Quốc Đạt\nĐịa chỉ: 600 Cần Thơ").setTextAlignment(TextAlignment.LEFT));
        document.add(new Paragraph("PHIẾU NHẬP KHO").setBold().setFontSize(16).setTextAlignment(TextAlignment.CENTER));
        document.add(new Paragraph("Ngày " + new SimpleDateFormat("dd").format(po.getOrderDate()) + " tháng " + new SimpleDateFormat("MM").format(po.getOrderDate()) + " năm " + new SimpleDateFormat("yyyy").format(po.getOrderDate())).setTextAlignment(TextAlignment.CENTER));
        document.add(new Paragraph("Số: PNK00" + po.getPoId()).setTextAlignment(TextAlignment.CENTER));
        document.add(new Paragraph("\n"));
        document.add(new Paragraph("Họ tên người giao: " + po.getSupplierName()));
        document.add(new Paragraph("Theo đơn hàng mua số: #" + po.getPoId()));
        document.add(new Paragraph("Nhập tại kho: Kho chính"));

        // --- Bảng chi tiết sản phẩm ---
        Table table = new Table(UnitValue.createPercentArray(new float[]{1, 4, 2, 2, 2, 2, 3}));
        table.setWidth(UnitValue.createPercentValue(100)).setMarginTop(15);
        table.addHeaderCell(new Cell().add(new Paragraph("STT")));
        table.addHeaderCell(new Cell().add(new Paragraph("Tên sản phẩm")));
        table.addHeaderCell(new Cell().add(new Paragraph("Mã số (SKU)")));
        table.addHeaderCell(new Cell().add(new Paragraph("Đơn vị")));
        table.addHeaderCell(new Cell().add(new Paragraph("Số lượng")));
        table.addHeaderCell(new Cell().add(new Paragraph("Đơn giá")));
        table.addHeaderCell(new Cell().add(new Paragraph("Thành tiền")));

        DecimalFormat df = new DecimalFormat("#,##0");
        double totalAmount = 0;
        for (int i = 0; i < items.size(); i++) {
            PurchaseOrderItemDTO item = items.get(i);
            double subtotal = item.getQuantity() * item.getUnitPrice().doubleValue();
            totalAmount += subtotal;
            table.addCell(String.valueOf(i + 1));
            table.addCell(item.getProductName() + " (" + item.getSize() + "/" + item.getColor() + ")");
            table.addCell(item.getSku());
            table.addCell("Cái");
            table.addCell(new Cell().add(new Paragraph(String.valueOf(item.getQuantity()))).setTextAlignment(TextAlignment.RIGHT));
            table.addCell(new Cell().add(new Paragraph(df.format(item.getUnitPrice()))).setTextAlignment(TextAlignment.RIGHT));
            table.addCell(new Cell().add(new Paragraph(df.format(subtotal))).setTextAlignment(TextAlignment.RIGHT));
        }
        document.add(table);

        // --- Phần Footer ---
        document.add(new Paragraph("Tổng cộng: " + df.format(totalAmount) + " VNĐ").setBold().setTextAlignment(TextAlignment.RIGHT));
        document.add(new Paragraph("\n\n"));
        Table signatureTable = new Table(UnitValue.createPercentArray(4)).setWidth(UnitValue.createPercentValue(100));
        signatureTable.addCell(new Cell().add(new Paragraph("Người lập phiếu\n(Ký, họ tên)")).setTextAlignment(TextAlignment.CENTER).setBorder(null));
        signatureTable.addCell(new Cell().add(new Paragraph("Người giao hàng\n(Ký, họ tên)")).setTextAlignment(TextAlignment.CENTER).setBorder(null));
        signatureTable.addCell(new Cell().add(new Paragraph("Thủ kho\n(Ký, họ tên)")).setTextAlignment(TextAlignment.CENTER).setBorder(null));
        signatureTable.addCell(new Cell().add(new Paragraph("Kế toán trưởng\n(Ký, họ tên)")).setTextAlignment(TextAlignment.CENTER).setBorder(null));
        document.add(signatureTable);

        document.close();

    }
}
