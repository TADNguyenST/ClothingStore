package model;

public class Ward {

    private long wardId;
    private String name;
    private String code;
    private long districtId;

    // Getters and Setters
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

    public long getDistrictId() {
        return districtId;
    }

    public void setDistrictId(long districtId) {
        this.districtId = districtId;
    }
}
