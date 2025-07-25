package DTO;

/**
 * Lớp chuẩn hóa cấu trúc cho mọi phản hồi API (JSON) từ server.
 * Giúp client dễ dàng xử lý kết quả trả về.
 * @param <T> Kiểu dữ liệu của payload (phần data)
 */
public class ApiResponse<T> {
    private String status; // "success" hoặc "error"
    private String message;
    private T data;

    public ApiResponse() {}

    // --- Factory methods tiện lợi ---
    public static <T> ApiResponse<T> success(T data, String message) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus("success");
        response.setMessage(message);
        response.setData(data);
        return response;
    }

    public static <T> ApiResponse<T> success(T data) {
        return success(data, null);
    }

    public static ApiResponse<Object> error(String message) {
        ApiResponse<Object> response = new ApiResponse<>();
        response.setStatus("error");
        response.setMessage(message);
        return response;
    }

    // --- Getters and Setters ---
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public T getData() { return data; }
    public void setData(T data) { this.data = data; }
}