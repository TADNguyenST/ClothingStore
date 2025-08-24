package model;

public class Province {

    private long provinceId;
    private String name;
    private String code; // mã theo API v2 (string)

    public Province() {
    }

    public Province(long provinceId, String name, String code) {
        this.provinceId = provinceId;
        this.name = name;
        this.code = code;
    }

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
