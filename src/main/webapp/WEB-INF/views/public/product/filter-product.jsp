<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="filter-panel">
    <style>
        .filter-panel {
            padding: 20px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            max-width: 100%;
        }
        .filter-section {
            margin-bottom: 20px;
        }
        .filter-section h3 {
            font-size: 1.1rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .color-swatches {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            width: 100%;
        }
        .color-swatches label {
            margin: 0;
            display: flex;
            align-items: center;
        }
        .color-circle {
            width: 25px;
            height: 25px;
            border-radius: 50%;
            border: 1px solid #ddd;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            margin-right: 5px !important;
        }
        .color-circle:hover {
            transform: scale(1.1) !important;
            box-shadow: 0 0 5px rgba(0, 0, 0, 0.2) !important;
        }
        .size-options {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            width: 100%;
        }
        .size-options label {
            margin: 0;
            display: flex;
            align-items: center;
        }
        .size-option {
            padding: 6px 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
            cursor: pointer;
            background-color: #f8f9fa;
            transition: background-color 0.2s ease;
            color: #333;
        }
        .size-option:hover, .size-option.active {
            background-color: #007bff !important;
            color: #fff !important;
            border-color: #0056b3 !important;
        }
        .price-range {
            margin: 10px 0;
        }
        .price-range output {
            display: block;
            font-size: 0.9rem;
            color: #555;
            margin-top: 5px;
        }
        .price-range input[type="range"] {
            width: 100%;
            margin-top: 10px;
        }
        .brand-list {
            max-height: 150px;
            overflow-y: auto;
            padding-right: 5px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .brand-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            cursor: pointer;
        }
        .brand-item input[type="checkbox"] {
            margin: 0;
            position: absolute;
            opacity: 0;
        }
        .brand-item label {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin: 0;
            font-size: 0.8rem;
            color: #333;
            text-align: center;
            padding: 5px;
        }
        .brand-item img {
            width: 40px;
            height: 40px;
            object-fit: contain;
            border: 1px solid #ddd;
            border-radius: 4px;
            transition: border-color 0.2s ease, transform 0.2s ease;
        }
        .brand-item input[type="checkbox"]:checked + label img {
            border-color: #007bff;
            transform: scale(1.05);
        }
        .brand-item input[type="checkbox"]:focus + label img {
            outline: 2px solid #007bff;
            outline-offset: 2px;
        }
        .filter-actions {
            margin-top: 20px;
        }
        .filter-actions button {
            width: 100%;
            padding: 10px;
            margin-bottom: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: background-color 0.2s ease;
            box-sizing: border-box !important;
        }
        .filter-actions .apply-btn {
            background-color: #007bff !important;
            color: #fff !important;
        }
        .filter-actions .apply-btn:hover {
            background-color: #0056b3 !important;
        }
        .filter-actions .clear-btn {
            background-color: #6c757d !important;
            color: #fff !important;
        }
        .filter-actions .clear-btn:hover {
            background-color: #5a6268 !important;
        }
        .filter-panel input[type="checkbox"] {
            margin-right: 5px;
        }
        @media (max-width: 768px) {
            .filter-panel {
                padding: 15px;
            }
            .color-swatches, .size-options {
                justify-content: center;
            }
            .brand-list {
                justify-content: center;
            }
            .filter-actions button {
                padding: 8px;
                font-size: 0.85rem;
            }
        }
    </style>

    <div class="filter-section">
        <h3>Colors</h3>
        <div class="color-swatches">
            <label><input type="checkbox" name="colors" value="white" onchange="updateFilterUI(this)"><span style="background: white; border: 1px solid #ccc;" class="color-circle"></span></label>
            <label><input type="checkbox" name="colors" value="black" onchange="updateFilterUI(this)"><span style="background: black;" class="color-circle"></span></label>
            <label><input type="checkbox" name="colors" value="blue" onchange="updateFilterUI(this)"><span style="background: blue;" class="color-circle"></span></label>
            <label><input type="checkbox" name="colors" value="red" onchange="updateFilterUI(this)"><span style="background: red;" class="color-circle"></span></label>
            <label><input type="checkbox" name="colors" value="yellow" onchange="updateFilterUI(this)"><span style="background: yellow;" class="color-circle"></span></label>
            <label><input type="checkbox" name="colors" value="green" onchange="updateFilterUI(this)"><span style="background: green;" class="color-circle"></span></label>
            <label><input type="checkbox" name="colors" value="gray" onchange="updateFilterUI(this)"><span style="background: gray;" class="color-circle"></span></label>
            <label><input type="checkbox" name="colors" value="navy" onchange="updateFilterUI(this)"><span style="background: navy;" class="color-circle"></span></label>
        </div>
    </div>

    <div class="filter-section">
        <h3>Sizes</h3>
        <div class="size-options">
            <label><input type="checkbox" name="sizes" value="XS" onchange="updateFilterUI(this)" class="size-option">XS</label>
            <label><input type="checkbox" name="sizes" value="S" onchange="updateFilterUI(this)" class="size-option">S</label>
            <label><input type="checkbox" name="sizes" value="M" onchange="updateFilterUI(this)" class="size-option">M</label>
            <label><input type="checkbox" name="sizes" value="L" onchange="updateFilterUI(this)" class="size-option">L</label>
            <label><input type="checkbox" name="sizes" value="XL" onchange="updateFilterUI(this)" class="size-option">XL</label>
            <label><input type="checkbox" name="sizes" value="XXL" onchange="updateFilterUI(this)" class="size-option">XXL</label>
        </div>
    </div>

    <div class="filter-section">
        <h3>Price Range</h3>
        <div class="price-range">
            <input type="range" name="priceRange" min="0" max="2000000" step="50000" value="0" oninput="this.nextElementSibling.value = this.value === '0' ? 'All' : this.value + ' VND'">
            <output>0 VND</output>
        </div>
    </div>

    <div class="filter-section">
        <h3>Brands</h3>
        <div class="brand-list">
            <c:if test="${empty brands}">
                <p style="color: #777;">No brands available.</p>
            </c:if>
            <c:forEach var="brand" items="${brands}">
                <div class="brand-item">
                    <input type="checkbox" name="brands" value="${brand.brandId}" id="brand-${brand.brandId}" onchange="updateFilterUI(this)">
                    <label for="brand-${brand.brandId}">
                        <img src="${brand.logoUrl != null ? brand.logoUrl : 'https://placehold.co/50x50?text=' + brand.name}" alt="${brand.name}">
                        <span>${brand.name}</span>
                    </label>
                </div>
            </c:forEach>
        </div>
    </div>

    <input type="hidden" name="parentCategoryId" value="${param.parentCategoryId}">
    <input type="hidden" name="categoryId" value="${param.categoryId}">

    <div class="filter-actions">
        <button class="apply-btn" onclick="submitFilter()">Apply Filters</button>
        <button class="clear-btn" onclick="clearFilters()">Clear Filters</button>
    </div>
</div>

<script>
function updateFilterUI(checkbox) {
    const label = checkbox.parentElement;
    if (checkbox.checked) {
        label.classList.add('active');
    } else {
        label.classList.remove('active');
    }
}

function clearFilters() {
    document.querySelectorAll('input[name="colors"]').forEach(cb => cb.checked = false);
    document.querySelectorAll('input[name="sizes"]').forEach(cb => cb.checked = false);
    document.querySelectorAll('input[name="brands"]').forEach(cb => cb.checked = false);
    document.querySelector('input[name="priceRange"]').value = '0';
    document.querySelector('input[name="priceRange"]').nextElementSibling.value = 'All';
    document.querySelectorAll('.color-circle').forEach(circle => circle.classList.remove('active'));
    document.querySelectorAll('.size-option').forEach(option => option.classList.remove('active'));
    document.querySelectorAll('.brand-item label').forEach(label => label.classList.remove('active'));
    submitFilter();
}
</script>