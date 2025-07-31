//package service;
//
//import dao.CustomerDAO;
//import dao.CustomerVoucherDAO;
//import dao.VoucherDAO;
//import dao.UserDAO;
//import model.Customer;
//import model.Users;
//import model.Voucher;
//import util.EmailService;
//import util.FileService;
//
//import java.sql.SQLException;
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//import java.util.logging.Level;
//import java.util.logging.Logger;
//
//public class VoucherService {
//
//    private VoucherDAO voucherDAO;
//    private CustomerDAO customerDAO;
//    private CustomerVoucherDAO customerVoucherDAO;
//    private UserDAO userDAO;
//    private EmailService emailService;
//    private FileService fileService;
//    private static final Logger LOGGER = Logger.getLogger(VoucherService.class.getName());
//
//    public VoucherService() {
//        this.voucherDAO = new VoucherDAO();
//        this.customerDAO = new CustomerDAO();
//        this.customerVoucherDAO = new CustomerVoucherDAO();
//        this.userDAO = new UserDAO();
//        this.fileService = new FileService(); // Initialize FileService
//        this.emailService = new EmailService(new FileService()); // Pass FileService to EmailService
//    }
//
//    public List<Voucher> getAllVouchers() throws SQLException {
//        return voucherDAO.getAllVouchers();
//    }
//
//    public List<Users> getAllCustomersWithUserDetails() throws SQLException {
//        return customerDAO.getAllCustomersWithUserDetails();
//    }
//
//    public boolean sendVouchersToCustomers(List<Integer> voucherId, List<String> customerEmails) {
//        try {
//            
//
//            boolean overallSuccess = true;
//
//            for (Integer currentVoucherId : voucherId) { // Renamed voucherId to currentVoucherId to avoid confusion
//                Voucher voucher = voucherDAO.getVoucherById(currentVoucherId);
//                if (voucher == null) {
//                    LOGGER.log(Level.WARNING, "Voucher with ID {0} not found. Skipping.", currentVoucherId);
//                    overallSuccess = false;
//                    continue;
//                }
//
//                for (String email : customerEmails) {
//                    Users user = userDAO.getUserByEmail(email);
//                    if (user != null) {
//                        Customer customer = customerDAO.getCustomerByUserId(user.getUserId());
//                        if (customer != null) {
//                            // Add voucher to customer_vouchers table
//                            boolean added = customerVoucherDAO.addCustomerVoucher(customer.getCustomerId(), currentVoucherId);
//                            if (added) {
//                                // Prepare variables for email template
//                                Map<String, Object> emailVariables = new HashMap<>();
//                                emailVariables.put("fullName", user.getFullName());
//                                emailVariables.put("voucherName", voucher.getName());
//                                emailVariables.put("voucherCode", voucher.getCode());
//                                emailVariables.put("discountType", voucher.getDiscountType());
//                                emailVariables.put("discountValue", voucher.getDiscountValue());
//                                emailVariables.put("minimumOrderAmount", voucher.getMinimumOrderAmount());
//                                emailVariables.put("maximumDiscountAmount", voucher.getMaximumDiscountAmount());
//                                emailVariables.put("expirationDate", voucher.getExpirationDate());
//
//                                // Send HTML email using EmailService
//                                emailService.sendEmail(email, "You've received a new voucher!", "voucher_email", emailVariables, null);
//                                LOGGER.log(Level.INFO, "Voucher {0} sent to customer {1} ({2})", new Object[]{currentVoucherId, customer.getCustomerId(), email});
//                            } else {
//                                LOGGER.log(Level.WARNING, "Failed to add voucher {0} to customer {1} ({2}) in database.", new Object[]{currentVoucherId, customer.getCustomerId(), email});
//                                overallSuccess = false;
//                            }
//                        } else {
//                            LOGGER.log(Level.WARNING, "Customer details not found for user with email {0}.", email);
//                            overallSuccess = false;
//                        }
//                    } else {
//                        LOGGER.log(Level.WARNING, "User with email {0} not found.", email);
//                        overallSuccess = false;
//                    }
//                }
//            }
//            return overallSuccess;
//        } catch (SQLException e) {
//            LOGGER.log(Level.SEVERE, "Database error while sending vouchers: {0}", e.getMessage());
//            return false;
//        } catch (Exception e) {
//            LOGGER.log(Level.SEVERE, "An unexpected error occurred while sending vouchers: {0}", e.getMessage());
//            return false;
//        }
//    }
//}