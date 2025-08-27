package util;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import dao.ProvinceDAO;
import dao.WardDAO;
import model.Province;
import model.Ward;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Seeder 2 cấp (Province -> Ward) API v2: - GET /api/v2/p/ -> list provinces
 * (34) - GET /api/v2/p/{code}?depth=2 -> province detail + wards[] Lưu ý:
 * V2_ONLY = true -> không fallback về v1.
 */
public class DataSeederV2 {

    private static final String BASE_V2 = "https://provinces.open-api.vn/api/v2";
    private static final boolean V2_ONLY = true;

    private static final Gson gson = new Gson();
    private static final ProvinceDAO provinceDAO = new ProvinceDAO();
    private static final WardDAO wardDAO = new WardDAO();

    // DTO v2
    static class ProvinceV2Dto {

        String code;
        String name;
        List<WardDto> wards; // có khi null nếu không truyền depth=2
    }

    static class WardDto {

        String code;
        String name;
    }

    // (Fallback DTO v1 – chỉ để giữ code compile nếu sau này bật lại)
    static class ProvinceV1Dto {

        String code;
        String name;
        List<DistrictV1Dto> districts;
    }

    static class DistrictV1Dto {

        String code;
        String name;
        List<WardDto> wards;
    }

    public static void main(String[] args) throws Exception {
        System.out.println("=== Start seeding provinces & wards (2-level, API v2 only) ===");

        // 1) Provinces (v2)
        List<ProvinceV2Dto> provinces = fetchProvincesV2();
        if (provinces == null || provinces.isEmpty()) {
            throw new IllegalStateException("API v2 không trả dữ liệu. Dừng để tránh seed sai bộ mã.");
        }

        // Upsert provinces
        List<Province> toSave = new ArrayList<>();
        for (ProvinceV2Dto p : provinces) {
            Province m = new Province();
            m.setName(p.name);
            m.setCode(p.code);
            toSave.add(m);
        }
        provinceDAO.save(toSave);
        System.out.println("Saved/updated provinces: " + toSave.size() + " (v2)");

        // 2) Wards per province
        int totalWards = 0;
        for (ProvinceV2Dto p : provinces) {
            try {
                List<WardDto> wards = fetchWardsForProvince(p.code);
                if (wards == null) {
                    wards = Collections.emptyList();
                }

                long provinceId = Optional.ofNullable(provinceDAO.findByCode(p.code))
                        .map(Province::getProvinceId)
                        .orElseThrow(() -> new RuntimeException("Province not found after upsert: " + p.code));

                List<Ward> models = new ArrayList<>();
                HashSet<String> seen = new HashSet<>();
                for (WardDto w : wards) {
                    if (w == null || w.code == null) {
                        continue;
                    }
                    if (!seen.add(w.code)) {
                        continue; // de-dup
                    }
                    Ward wm = new Ward();
                    wm.setName(w.name);
                    wm.setCode(w.code);
                    models.add(wm);
                }

                wardDAO.save(models, provinceId);
                totalWards += models.size();
                System.out.println(" -> " + p.name + ": " + models.size() + " wards");
            } catch (Exception ex) {
                System.out.println(" -> " + p.name + ": 0 wards (error: " + ex.getMessage() + ")");
            }
        }

        System.out.println("=== Done. Total wards saved: " + totalWards + " ===");
    }

    /* =================== Fetchers (v2) =================== */
    private static List<ProvinceV2Dto> fetchProvincesV2() {
        try {
            String json = httpGet(BASE_V2 + "/p/");
            Type listType = new TypeToken<List<ProvinceV2Dto>>() {
            }.getType();
            return gson.fromJson(json, listType);
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    private static List<WardDto> fetchWardsForProvince(String provinceCode) {
        try {
            String json = httpGet(BASE_V2 + "/p/" + encode(provinceCode) + "?depth=2");
            ProvinceV2Dto detail = gson.fromJson(json, ProvinceV2Dto.class);
            if (detail != null && detail.wards != null) {
                // đảm bảo unique theo code
                Map<String, WardDto> uniq = detail.wards.stream()
                        .filter(w -> w.code != null)
                        .collect(Collectors.toMap(w -> w.code, w -> w, (a, b) -> a));
                return new ArrayList<>(uniq.values());
            }
        } catch (Exception ignored) {
        }
        return Collections.emptyList();
    }

    /* =================== Helpers =================== */
    private static String httpGet(String urlStr) throws Exception {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(urlStr);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(40000);
            conn.setRequestProperty("User-Agent", "ClothingStore-Seed/1.0");

            int code = conn.getResponseCode();
            if (code != 200) {
                throw new RuntimeException("HTTP " + code + " for " + urlStr);
            }

            try ( BufferedReader br
                    = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    sb.append(line);
                }
                return sb.toString();
            }
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    private static String encode(String s) {
        try {
            return s == null ? "" : URLEncoder.encode(s.trim(), "UTF-8");
        } catch (Exception e) {
            return s;
        }
    }
}
