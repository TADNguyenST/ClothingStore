<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Voucher"%>
<%@ page import="model.Users" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Send Vouchers</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .container {
            margin-top: 50px;
        }
        .card {
            border: none;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }
        .form-check-scroll {
            max-height: 200px;
            overflow-y: auto;
            border: 1px solid #dee2e6;
            border-radius: 0.25rem;
            padding: 10px;
        }
         .content-area {
        position: relative;
        margin-left: 260px;
        padding: 1.5rem;
        width: calc(100% - 260px);
        transition: all 0.5s ease;
        min-height: 100vh;
    }
    .sidebar.close ~ .content-area {
        margin-left: 88px;
        width: calc(100% - 88px);
    }
    .sidebar.hidden ~ .content-area {
        margin-left: 0;
        width: 100%;
    }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    <div class="content-area">
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h1 class="card-title mb-0">Send Vouchers to Customers</h1>
            </div>
            <div class="card-body">
                <% if (request.getAttribute("message") != null) { %>
                    <div class="alert alert-success" role="alert">
                        <%= request.getAttribute("message") %>
                    </div>
                <% } %>
                <% if (request.getAttribute("errorMessage") != null) { %>
                    <div class="alert alert-danger" role="alert">
                        <%= request.getAttribute("errorMessage") %>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/admin/sendvouchers" method="post">
                    <div class="mb-3">
                        <label for="voucherIds" class="form-label">Vouchers:</label>
                        <select id="voucherIds" name="voucherIds" class="form-select" multiple required size="5">
                            <% 
                                List<Voucher> vouchers = (List<Voucher>) request.getAttribute("vouchers");
                                if (vouchers != null) {
                                    for (Voucher voucher : vouchers) {
                            %>
                                        <option value="<%= voucher.getVoucherId() %>"><%= voucher.getName() %> (<%= voucher.getCode() %>)</option>
                            <% 
                                    }
                                }
                            %>
                        </select>
                        <small class="form-text text-muted">Hold Ctrl (Windows) or Command (Mac) to select multiple vouchers.</small>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Select Customers:</label>
                        <input type="text" id="customerSearch" class="form-control mb-2" placeholder="Search customers...">
                        <div class="form-check-scroll" id="customerList">
                            <% 
                                List<Users> customers = (List<Users>) request.getAttribute("customers");
                                if (customers != null) {
                                    for (Users customer : customers) {
                            %>
                                        <div class="form-check customer-item" data-name="<%= customer.getFullName().toLowerCase() %>" data-email="<%= customer.getEmail().toLowerCase() %>">
                                            <input class="form-check-input" type="checkbox" name="customerEmails" value="<%= customer.getEmail() %>" id="customer<%= customer.getUserId() %>">
                                            <label class="form-check-label" for="customer<%= customer.getUserId() %>">
                                                <%= customer.getFullName() %> (<%= customer.getEmail() %>)
                                            </label>
                                        </div>
                            <% 
                                    }
                                }
                            %>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary">Send Vouchers</button>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('customerSearch').addEventListener('keyup', function() {
            let filter = this.value.toLowerCase();
            let customerItems = document.querySelectorAll('.customer-item');

            customerItems.forEach(item => {
                let name = item.dataset.name;
                let email = item.dataset.email;
                if (name.includes(filter) || email.includes(filter)) {
                    item.style.display = '';
                } else {
                    item.style.display = 'none';
                }
            });
        });
    </script>
</body>
</html>