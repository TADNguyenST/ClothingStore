package model;

public class Ward {

    private long wardId;
    private String name;
    private String code;       // mã theo API v2 (string)
    private long provinceId;   // liên kết trực tiếp về tỉnh (không còn districtId)

    public Ward() {
    }

    public Ward(long wardId, String name, String code, long provinceId) {
        this.wardId = wardId;
        this.name = name;
        this.code = code;
        this.provinceId = provinceId;
    }

    public long getWardId() {
        return wardId;
    }

    public void setWardId(long wardId) {
        this.wardId = wardId;
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

    public long getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(long provinceId) {
        this.provinceId = provinceId;
    }
}
