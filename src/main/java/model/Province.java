package model;

public class Province {

    private long provinceId;
    private String name;
    private String code;

    // --- Getters and Setters ---
    // Vấn đề nằm ở đây, bạn cần có ĐẦY ĐỦ các phương thức này
    public long getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(long provinceId) {
        this.provinceId = provinceId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }
}
