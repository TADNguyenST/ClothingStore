<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="filter-panel">
    <style>
    .filter-panel { padding: 10px; }
    .color-circle { display: inline-block; width: 20px; height: 20px; border-radius: 50%; margin: 5px; vertical-align: middle; }
    .filter-panel h3 { font-size: 1.2rem; margin-top: 15px; }
    .filter-panel div { margin-bottom: 10px; }
    .filter-panel button { width: 100%; padding: 10px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
    .filter-panel button:hover { background: #0056b3; }
    </style>

    <h3>Colors</h3>
    <div>
        <input type="checkbox" name="colors" value="white"> <span style="background: white; border: 1px solid #ccc;" class="color-circle"></span> White
        <input type="checkbox" name="colors" value="black"> <span style="background: black;" class="color-circle"></span> Black
        <input type="checkbox" name="colors" value="blue"> <span style="background: blue;" class="color-circle"></span> Blue
        <input type="checkbox" name="colors" value="red"> <span style="background: red;" class="color-circle"></span> Red
        <input type="checkbox" name="colors" value="yellow"> <span style="background: yellow;" class="color-circle"></span> Yellow
        <input type="checkbox" name="colors" value="green"> <span style="background: green;" class="color-circle"></span> Green
    </div>

    <h3>Sizes</h3>
    <div>
        <input type="checkbox" name="sizes" value="XS"> XS
        <input type="checkbox" name="sizes" value="S"> S
        <input type="checkbox" name="sizes" value="M"> M
        <input type="checkbox" name="sizes" value="L"> L
        <input type="checkbox" name="sizes" value="XL"> XL
    </div>

    <h3>Price</h3>
    <div>
        <input type="range" name="priceRange" min="0" max="2000000" step="50000" oninput="this.nextElementSibling.value = this.value + ' VND'" value="0">
        <output>0 VND</output>
    </div>

    <h3>Brands</h3>
    <div>
        <c:if test="${empty brands}">
            <p>No brands to display.</p>
        </c:if>
        <c:forEach var="brand" items="${brands}">
            <input type="checkbox" name="brands" value="${brand.brandId}"> ${brand.name}<br>
        </c:forEach>
    </div>

    <input type="hidden" name="parentCategoryId" value="${param.parentCategoryId}">
    <input type="hidden" name="categoryId" value="${param.categoryId}">

    <button onclick="submitFilter()">Apply</button>
</div>