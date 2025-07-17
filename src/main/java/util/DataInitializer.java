package util;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import dao.DistrictDAO;
import dao.ProvinceDAO;
import dao.WardDAO;
import model.District;
import model.Province;
import model.Ward;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DataInitializer {

    private static final String API_BASE_URL = "https://provinces.open-api.vn/api/";
    private static final Gson gson = new Gson();
    private static final ProvinceDAO provinceDAO = new ProvinceDAO();
    private static final DistrictDAO districtDAO = new DistrictDAO();
    private static final WardDAO wardDAO = new WardDAO();

    public static void main(String[] args) {
        System.out.println("Starting data initialization process...");

        try {
            importProvinces();
            importDistricts();
            importWards();
            System.out.println("Data initialization process completed successfully!");

        } catch (Exception e) {
            Logger.getLogger(DataInitializer.class.getName()).log(Level.SEVERE, "Data initialization failed.", e);
        }
    }

    private static void importProvinces() throws IOException {
        System.out.println("Fetching and saving provinces...");
        String json = fetchDataFromApi(API_BASE_URL + "p/");
        List<Province> provinces = gson.fromJson(json, new TypeToken<List<Province>>() {
        }.getType());
        if (provinces != null && !provinces.isEmpty()) {
            provinceDAO.save(provinces);
            System.out.println("Successfully saved " + provinces.size() + " provinces.");
        }
    }

    private static void importDistricts() throws IOException {
        System.out.println("Fetching and saving districts...");
        String json = fetchDataFromApi(API_BASE_URL + "d/");
        List<District> districts = gson.fromJson(json, new TypeToken<List<District>>() {
        }.getType());
        if (districts != null && !districts.isEmpty()) {
            districtDAO.save(districts);
            System.out.println("Successfully saved " + districts.size() + " districts.");
        }
    }

    private static void importWards() {
        System.out.println("Fetching and saving wards. This may take a while...");
        List<District> districtsFromDb = districtDAO.getAllDistricts();

        for (District district : districtsFromDb) {
            System.out.println(" -> Fetching wards for district: " + district.getName());
            try {
                String json = fetchDataFromApi(API_BASE_URL + "d/" + district.getCode() + "?depth=2");
                District districtWithWards = gson.fromJson(json, District.class);
                if (districtWithWards != null && districtWithWards.getWards() != null && !districtWithWards.getWards().isEmpty()) {
                    wardDAO.save(districtWithWards.getWards(), district.getDistrictId());
                }
            } catch (IOException e) {
                System.err.println("    Could not fetch wards for " + district.getName() + ". Error: " + e.getMessage());
            }
        }
    }

    private static String fetchDataFromApi(String apiUrl) throws IOException {
        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);
        int responseCode = conn.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_OK) {
            throw new IOException("HTTP error! Status: " + responseCode + " for URL: " + apiUrl);
        }
        StringBuilder result = new StringBuilder();
        try ( BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
            String line;
            while ((line = reader.readLine()) != null) {
                result.append(line);
            }
        } finally {
            conn.disconnect();
        }
        return result.toString();
    }
}
