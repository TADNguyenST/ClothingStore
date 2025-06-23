<%-- ================ FILE: /WEB-INF/views/common/footer.jsp ================ --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

</main> <%-- Đóng thẻ main từ header --%>

<style>
    /* CSS cho Footer */
    .main-footer {
        background-color: #f8f9fa;
        color: #6c757d;
        padding: 4rem 0 0;
    }
    .footer-heading {
        font-size: 1rem;
        font-weight: 600;
        color: #343a40;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 1.5rem;
    }
    .footer-links li {
        margin-bottom: 0.75rem;
    }
    .footer-links a {
        color: #6c757d;
        text-decoration: none;
        transition: color 0.3s ease;
    }
    .footer-links a:hover {
        color: #111;
        text-decoration: underline;
    }
    .footer-social-icons a {
        color: #6c757d;
        font-size: 1.2rem;
        margin-right: 1rem;
        transition: color 0.3s ease;
    }
    .footer-social-icons a:hover {
        color: #111;
    }
    .footer-bottom {
        border-top: 1px solid #dee2e6;
        padding: 1.5rem 0;
        margin-top: 3rem;
    }
    .footer-payment-icons i {
        color: #495057;
    }
</style>

<footer class="main-footer">
    <div class="container">
        <div class="row">
            <div class="col-lg-3 col-md-6 mb-4 mb-lg-0">
                <h5 class="footer-heading">CLOTHING</h5>
                <p class="small">The best place to find your style. We offer high-quality clothing for men and women with unique designs.</p>
            </div>
            <div class="col-lg-2 col-md-6 mb-4 mb-lg-0">
                <h5 class="footer-heading">Shop</h5>
                <ul class="list-unstyled footer-links">
                    <li><a href="#">Men's Collection</a></li>
                    <li><a href="#">Women's Collection</a></li>
                    <li><a href="#">New Arrivals</a></li>
                    <li><a href="#">On Sale</a></li>
                </ul>
            </div>
            <div class="col-lg-3 col-md-6 mb-4 mb-lg-0">
                <h5 class="footer-heading">Help & Support</h5>
                <ul class="list-unstyled footer-links">
                    <li><a href="#">Contact Us</a></li>
                    <li><a href="#">Frequently Asked Questions</a></li>
                    <li><a href="#">Shipping & Returns</a></li>
                    <li><a href="#">Privacy Policy</a></li>
                    <li><a href="#">Terms of Service</a></li>
                </ul>
            </div>
            <div class="col-lg-4 col-md-6 mb-4 mb-lg-0">
                <h5 class="footer-heading">Stay Connected</h5>
                <p class="small">Subscribe to our newsletter to get the latest updates and special offers.</p>
                <form action="#" method="post" class="d-flex mb-4">
                    <input type="email" class="form-control" placeholder="Enter your email" required>
                    <button type="submit" class="btn btn-dark ms-2">Go</button>
                </form>
                <div class="footer-social-icons">
                    <a href="#"><i class="fab fa-facebook-f"></i></a>
                    <a href="#"><i class="fab fa-instagram"></i></a>
                    <a href="#"><i class="fab fa-pinterest-p"></i></a>
                    <a href="#"><i class="fab fa-tiktok"></i></a>
                </div>
            </div>
        </div>
        <div class="footer-bottom d-flex flex-column flex-md-row justify-content-between align-items-center">
            <c:set var="currentYear"><jsp:useBean id="date" class="java.util.Date" /><fmt:formatDate value="${date}" pattern="yyyy" /></c:set>
            <p class="small mb-3 mb-md-0">&copy; ${currentYear} ClothingStore. All Rights Reserved.</p>
            <div class="footer-payment-icons">
                <i class="fab fa-cc-visa fa-2x mx-1"></i>
                <i class="fab fa-cc-mastercard fa-2x mx-1"></i>
                <i class="fab fa-cc-paypal fa-2x mx-1"></i>
                <i class="fab fa-cc-jcb fa-2x mx-1"></i>
            </div>
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

</body>
</html>