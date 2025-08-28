<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="pageTitle" value="Supplier Management" scope="request"/>
<c:set var="currentModule" value="supplier" scope="request"/>
<c:set var="currentUser" value="${sessionScope.admin != null ? sessionScope.admin : sessionScope.staff}"/>
<c:set var="isAdmin" value="${currentUser.role == 'Admin'}"/>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Supplier Management</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

  <!-- ===== Look & feel khớp dashboard ===== -->
  <style>
    :root{
      --brand:#4f46e5;
      --ok:#16a34a;
      --warn:#f59e0b;
      --danger:#ef4444;
      --ink:#0f172a;
      --soft:#f8fafc;
      --radius:14px;
      --shadow:0 8px 30px rgba(2,6,23,.06);
      --hair:#e5e7eb;
    }

    body{ color:var(--ink); background:#fff; }

    /* layout khớp dashboard */
    .content-area{
      position:relative; margin-left:260px; padding:1.5rem;
      width:calc(100% - 260px); transition:all .5s ease; min-height:100vh;
      background:var(--soft);
    }
    .sidebar.close ~ .content-area{ margin-left:88px; width:calc(100% - 88px); }
    .sidebar.hidden ~ .content-area{ margin-left:0; width:100%; }

    /* box/card */
    .box{ background:#fff; border:1px solid var(--hair); border-radius:var(--radius); box-shadow:var(--shadow); }
    .box-header{ padding:1rem 1.25rem; border-bottom:1px solid var(--hair); border-top-left-radius:var(--radius); border-top-right-radius:var(--radius); }
    .box-title{ font-weight:700; letter-spacing:.2px; }
    .box-body{ padding:1rem 1.25rem 1.25rem; }

    /* page header */
    .page-actions .btn{ border-radius:999px; }
    .btn-brand{ background:var(--brand); border-color:var(--brand); color:#fff; }
    .btn-brand:hover{ filter:brightness(.95); color:#fff; }

    /* table modern */
    .table-modern{ --rowpad:.85rem; }
    .table-modern thead th{
      background:#f3f4f6; border-bottom:1px solid var(--hair); font-weight:600; color:#374151;
    }
    .table-modern th, .table-modern td{ vertical-align:middle; padding:var(--rowpad) 1rem; }
    .table-modern tbody tr{ transition:background .2s ease, transform .1s ease; }
    .table-modern tbody tr:hover{ background:#fafafa; }
    .table-modern .actions .btn{ border-radius:10px; }

    /* badge mềm */
    .badge-soft{ background:#eef2ff; color:#3730a3; }
    .badge-ok{ background:rgba(22,163,74,.12); color:#166534; }
    .badge-danger-soft{ background:rgba(239,68,68,.12); color:#991b1b; }

    /* modal custom (thuần css, không bootstrap modal) */
    .modal{ position:fixed; inset:0; background:rgba(15,23,42,.35); display:none; align-items:center; justify-content:center; z-index:1055; padding:1rem; }
    .modal.is-visible{ display:flex; }
    .modal-content-custom{
      width:min(820px, 100%); max-height:90vh; overflow:auto; background:#fff; border-radius:var(--radius);
      box-shadow:var(--shadow); padding:1.25rem 1.25rem 1rem; animation:popover .18s ease;
    }
    @keyframes popover{ from{ transform:translateY(6px); opacity:.6 } to{ transform:none; opacity:1 } }

    .po-list-container{ max-height:320px; overflow:auto; border:1px solid var(--hair); border-radius:12px; background:#fff; }

    /* form tweaks */
    .form-control, .form-select{ border-radius:12px; }
    .btn{ border-radius:12px; }

    /* chip trạng thái */
    .status-chip{ font-size:.8rem; padding:.35rem .6rem; border-radius:999px; font-weight:600; }
    .status-chip.active{ background:rgba(34,197,94,.14); color:#166534; }
    .status-chip.inactive{ background:rgba(239,68,68,.14); color:#991b1b; }

    /* khu vực rỗng */
    .empty-state{ text-align:center; padding:2rem 0; color:#6b7280; }
    .empty-state i{ opacity:.7; }

    /* nhỏ hơn md */
    @media (max-width: 992px){
      .content-area{ margin-left:0; width:100%; }
      .page-actions{ width:100%; display:flex; justify-content:flex-end; }
    }
    
  </style>
</head>
<body data-is-admin="${isAdmin}" data-context-path="${pageContext.request.contextPath}">

  <!-- ===== Modals ===== -->
  <!-- Add/Edit -->
  <div class="modal" id="supplierFormModal">
    <div class="modal-content-custom">
      <div class="d-flex justify-content-between align-items-center">
        <h4 id="formModalTitle" class="mb-0">Supplier Form</h4>
        <button type="button" class="btn btn-light btn-sm" id="cancelFormBtn"><i class="fa fa-times"></i></button>
      </div>
      <hr class="mt-3 mb-3">
      <form id="supplierForm" novalidate>
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" id="supplierId">

        <div id="form-errors" class="alert alert-danger d-none"></div>

        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label">Name *</label>
            <input type="text" name="name" id="supplierName" class="form-control" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Email *</label>
            <input type="email" name="email" id="supplierEmail" class="form-control" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Phone *</label>
            <input type="text" name="phone" id="supplierPhone" class="form-control" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Status</label>
            <select name="isActive" id="supplierIsActive" class="form-select">
              <option value="true">Active</option>
              <option value="false">Inactive</option>
            </select>
          </div>
          <div class="col-12">
            <label class="form-label">Address *</label>
            <textarea name="address" id="supplierAddress" class="form-control" rows="3" required></textarea>
          </div>
        </div>
        <div class="d-flex gap-2 justify-content-end mt-4">
          <button type="button" class="btn btn-light" id="cancelFormBtn2">Cancel</button>
          <button type="submit" class="btn btn-brand">Save</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Details -->
  <div class="modal" id="supplierDetailModal">
    <div class="modal-content-custom">
      <div class="d-flex justify-content-between align-items-center">
        <h4 class="mb-0">Details – <span id="detailSupplierName" class="text-primary"></span></h4>
        <button type="button" class="btn btn-light btn-sm" id="closeDetailBtn"><i class="fa fa-times"></i></button>
      </div>
      <hr class="mt-3 mb-3">

      <div class="row g-3 mb-3">
        <div class="col-md-6">
          <div class="p-3 rounded border" style="background:#fafafa">
            <div><strong>Email:</strong> <span id="detailEmail"></span></div>
            <div><strong>Phone:</strong> <span id="detailPhone"></span></div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="p-3 rounded border" style="background:#fafafa">
            <div><strong>Address:</strong> <span id="detailAddress"></span></div>
            <div><strong>Status:</strong> <span id="detailStatus" class="status-chip"></span></div>
          </div>
        </div>
      </div>

      <div class="p-3 bg-light rounded border mb-3">
        <form id="reportFilterForm" class="row g-2 align-items-end">
          <input type="hidden" name="id" id="detailSupplierId">
          <div class="col-md-4">
            <label class="form-label fw-semibold">From Date</label>
            <input type="date" name="startDate" id="startDate" class="form-control">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-semibold">To Date</label>
            <input type="date" name="endDate" id="endDate" class="form-control">
          </div>
          <div class="col-md-4 d-grid">
            <button type="submit" class="btn btn-brand mt-md-4">View Report</button>
          </div>
        </form>
      </div>

      <ul class="nav nav-tabs" id="supplierDetailTab" role="tablist">
        <li class="nav-item" role="presentation">
          <button class="nav-link active" id="financial-tab" data-bs-toggle="tab" data-bs-target="#financial" type="button" role="tab">Financials</button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="products-tab" data-bs-toggle="tab" data-bs-target="#products" type="button" role="tab">Products Supplied</button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="po-tab" data-bs-toggle="tab" data-bs-target="#po" type="button" role="tab">Purchase Orders</button>
        </li>
      </ul>

      <div class="tab-content" id="supplierDetailTabContent">
        <div class="tab-pane fade show active" id="financial" role="tabpanel">
          <div class="p-3">
            <div class="row g-3">
              <div class="col-md-6">
                <div class="card card-body text-center" style="border-radius:16px">
                  <h6 class="card-title text-muted mb-1">Delivered Orders</h6>
                  <div class="fs-3 fw-bold" id="statsOrderCount">-</div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="card card-body text-center" style="border-radius:16px">
                  <h6 class="card-title text-muted mb-1">Total Value</h6>
                  <div class="fs-3 fw-bold" id="statsTotalValue">-</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="tab-pane fade" id="products" role="tabpanel">
          <div class="po-list-container p-2">
            <table class="table table-sm table-striped align-middle mb-0">
              <thead>
                <tr><th>Product Name</th><th>SKU</th><th class="text-end">Total Quantity</th></tr>
              </thead>
              <tbody id="suppliedProductsTableBody"></tbody>
            </table>
          </div>
        </div>

        <div class="tab-pane fade" id="po" role="tabpanel">
          <div class="po-list-container p-2">
            <table class="table table-sm table-striped align-middle mb-0">
              <thead>
                <tr><th>PO ID</th><th>Notes</th><th>Date</th><th>Status</th><th>Action</th></tr>
              </thead>
              <tbody id="poListTableBody"></tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
  <!-- ===== Main ===== -->
  <c:choose>
    <c:when test="${not empty sessionScope.admin}">
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
    </c:when>
    <c:when test="${not empty sessionScope.staff}">
         <jsp:include page="/WEB-INF/views/staff/staff-sidebar.jsp" />
    </c:when>
</c:choose>
  <div class="main-content-wrapper">
    <main class="content-area">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="mb-0">Suppliers</h2>
        <div class="page-actions">
          <c:if test="${isAdmin}">
            <button id="addSupplierBtn" class="btn btn-brand"><i class="fas fa-plus me-2"></i>Add New Supplier</button>
          </c:if>
        </div>
      </div>

      <div class="box">
        <div class="box-body table-responsive">
          <table class="table table-modern table-hover align-middle mb-0">
            <thead>
              <tr>
                <th style="width:28%">Name</th>
                <th style="width:26%">Email</th>
                <th style="width:16%">Phone</th>
                <th style="width:12%">Status</th>
                <th style="width:18%">Actions</th>
              </tr>
            </thead>
            <tbody id="supplierTableBody">
              <!-- filled by JS -->
            </tbody>
          </table>

          <div id="supplierEmpty" class="empty-state d-none">
            <i class="fa-regular fa-box-open fa-2x mb-2"></i>
            <div>No suppliers found.</div>
          </div>
        </div>
      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

  <!-- ===== Logic (giữ nguyên, chỉ chỉnh nhẹ class/badge) ===== -->
  <script>
  document.addEventListener('DOMContentLoaded', function () {
    const isAdmin = document.body.dataset.isAdmin === 'true';
    const contextPath = document.body.dataset.contextPath;

    const supplierTableBody = document.getElementById('supplierTableBody');
    const supplierEmpty = document.getElementById('supplierEmpty');

    const addSupplierBtn = document.getElementById('addSupplierBtn');
    const formModal = document.getElementById('supplierFormModal');
    const formModalTitle = document.getElementById('formModalTitle');
    const supplierForm = document.getElementById('supplierForm');
    const cancelFormBtn = document.getElementById('cancelFormBtn');
    const cancelFormBtn2 = document.getElementById('cancelFormBtn2');
    const formErrorsDiv = document.getElementById('form-errors');

    const detailModal = document.getElementById('supplierDetailModal');
    const closeDetailBtn = document.getElementById('closeDetailBtn');
    const reportFilterForm = document.getElementById('reportFilterForm');

    const showModal = m => m.classList.add('is-visible');
    const hideModal = m => m.classList.remove('is-visible');

    const toast = (icon, title) => Swal.fire({ toast:true, position:'top-end', icon, title, showConfirmButton:false, timer:2500 });

    const currencyFormatter = new Intl.NumberFormat('vi-VN', { style:'currency', currency:'VND' });

    async function loadSuppliers(){
      supplierTableBody.innerHTML =
        '<tr><td colspan="5" class="text-center py-4"><div class="spinner-border" role="status"></div></td></tr>';
      supplierEmpty.classList.add('d-none');

      try{
        const res = await fetch(contextPath + '/Supplier?action=list');
        if(!res.ok){ throw new Error('HTTP ' + res.status); }
        const data = await res.json();

        supplierTableBody.innerHTML = '';
        if(!data || data.length===0){
          supplierEmpty.classList.remove('d-none');
          return;
        }

        data.forEach(s=>{
          const status = s.isActive
            ? '<span class="status-chip active">Active</span>'
            : '<span class="status-chip inactive">Inactive</span>';

          let adminButtons = '';
          if(isAdmin){
            const toggleAction = s.isActive ? 'deactivate' : 'reactivate';
            const toggleText = s.isActive ? 'Deactivate' : 'Reactivate';
            const toggleClass = s.isActive ? 'btn-outline-danger' : 'btn-outline-success';
            adminButtons =
              '<button class="btn btn-outline-warning btn-sm edit-btn" data-id="'+s.supplierId+'">Edit</button>' +
              '<button class="btn '+toggleClass+' btn-sm toggle-status-btn" data-id="'+s.supplierId+'" data-action="'+toggleAction+'">'+toggleText+'</button>';
          }

          const row =
            '<tr>' +
              '<td>'+ s.name +'</td>' +
              '<td>'+ s.contactEmail +'</td>' +
              '<td>'+ s.phoneNumber +'</td>' +
              '<td>'+ status +'</td>' +
              '<td class="actions">' +
                '<div class="btn-group" role="group">' +
                  '<button class="btn btn-outline-primary btn-sm detail-btn" data-id="'+s.supplierId+'">Details</button>' +
                  adminButtons +
                '</div>' +
              '</td>' +
            '</tr>';

          supplierTableBody.insertAdjacentHTML('beforeend', row);
        });
      }catch(err){
        supplierTableBody.innerHTML =
          '<tr><td colspan="5" class="text-danger text-center">Error loading data: '+err.message+'</td></tr>';
      }
    }

    function openFormModal(s=null){
      formErrorsDiv.classList.add('d-none');
      supplierForm.reset();
      document.getElementById('supplierId').value = '';

      if(s){
        formModalTitle.textContent = 'Edit Supplier';
        document.getElementById('supplierId').value = s.supplierId;
        document.getElementById('supplierName').value = s.name;
        document.getElementById('supplierEmail').value = s.contactEmail;
        document.getElementById('supplierPhone').value = s.phoneNumber;
        document.getElementById('supplierAddress').value = s.address;
        document.getElementById('supplierIsActive').value = s.isActive.toString();
      }else{
        formModalTitle.textContent = 'Add New Supplier';
      }
      showModal(formModal);
    }

    async function handleSave(e){
      e.preventDefault();
      const url = contextPath + '/Supplier';

      const fd = new FormData(supplierForm);
      const body = new URLSearchParams(fd).toString();

      try{
        const res = await fetch(url, {
          method:'POST',
          headers:{ 'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8' },
          body
        });
        const json = await res.json();

        if(res.ok){
          hideModal(formModal);
          toast('success', json.message || 'Saved');
          loadSuppliers();
        }else{
          let html = 'Please correct the following errors:<ul>';
          (json.errors || []).forEach(e => html += '<li>'+e+'</li>');
          html += '</ul>';
          formErrorsDiv.innerHTML = html;
          formErrorsDiv.classList.remove('d-none');
        }
      }catch(err){
        toast('error', 'Unexpected error');
      }
    }

    async function toggleStatus(id, action){
      const confirm = await Swal.fire({
        title: 'Confirm',
        text: action==='deactivate'
          ? 'Deactivate this supplier?'
          : 'Reactivate this supplier?',
        icon: 'warning',
        showCancelButton:true
      });
      if(!confirm.isConfirmed) return;

      try{
        const res = await fetch(contextPath + '/Supplier', {
          method:'POST',
          headers:{ 'Content-Type':'application/x-www-form-urlencoded' },
          body:'action='+action+'&id='+id
        });
        const json = await res.json();
        if(res.ok){ toast('success', json.message || 'Done'); loadSuppliers(); }
        else{ toast('error', json.message || 'Failed'); }
      }catch(err){ toast('error', 'Error'); }
    }

    async function showDetails(id, filter=null){
      new bootstrap.Tab(document.getElementById('financial-tab')).show();
      let url = contextPath + '/Supplier?action=detail&id='+id;
      if(filter){
        Object.keys(filter).forEach(k=>{
          if(k!=='id' && filter[k]) url += '&'+encodeURIComponent(k)+'='+encodeURIComponent(filter[k]);
        });
      }
      try{
        const res = await fetch(url);
        if(!res.ok) throw new Error('Load detail failed');
        const data = await res.json();

        document.getElementById('detailSupplierName').textContent = data.supplier.name;
        document.getElementById('detailEmail').textContent = data.supplier.contactEmail;
        document.getElementById('detailPhone').textContent = data.supplier.phoneNumber;
        document.getElementById('detailAddress').textContent = data.supplier.address;
        document.getElementById('detailStatus').textContent = data.supplier.isActive ? 'Active' : 'Inactive';
        document.getElementById('detailStatus').className = 'status-chip ' + (data.supplier.isActive?'active':'inactive');

        document.getElementById('detailSupplierId').value = data.supplier.supplierId;
        document.getElementById('startDate').value = data.startDate || '';
        document.getElementById('endDate').value = data.endDate || '';

        document.getElementById('statsOrderCount').textContent = data.stats.orderCount || 0;
        document.getElementById('statsTotalValue').textContent = currencyFormatter.format(data.stats.totalValue || 0);

        const prodBody = document.getElementById('suppliedProductsTableBody');
        prodBody.innerHTML = '';
        if(data.suppliedProducts && data.suppliedProducts.length){
          data.suppliedProducts.forEach(p=>{
            prodBody.insertAdjacentHTML('beforeend',
              '<tr><td>'+p.productName+'</td><td>'+ (p.sku||'') +'</td><td class="text-end"><span class="badge badge-soft">'+(p.totalQuantity||0)+'</span></td></tr>'
            );
          });
        }else{
          prodBody.innerHTML = '<tr><td colspan="3" class="text-center text-muted">No products found.</td></tr>';
        }

        const poBody = document.getElementById('poListTableBody');
        poBody.innerHTML = '';
        if(data.poList && data.poList.length){
          data.poList.forEach(p=>{
            const d = new Date(p.orderDate).toLocaleDateString('vi-VN');
            poBody.insertAdjacentHTML('beforeend',
              '<tr><td>#'+p.poId+'</td><td>'+ (p.notes||'') +'</td><td>'+d+'</td><td><span class="badge badge-soft">'+p.status+'</span></td><td><a class="btn btn-sm btn-outline-primary" href="'+contextPath+'/PurchaseOrder?action=edit&poId='+p.poId+'">View</a></td></tr>'
            );
          });
        }else{
          poBody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">No purchase orders.</td></tr>';
        }

        showModal(detailModal);
      }catch(err){
        toast('error','Could not load details');
      }
    }

    // events
    if(addSupplierBtn){ addSupplierBtn.addEventListener('click', ()=>openFormModal()); }
    cancelFormBtn.addEventListener('click', ()=>hideModal(formModal));
    cancelFormBtn2.addEventListener('click', ()=>hideModal(formModal));
    closeDetailBtn.addEventListener('click', ()=>hideModal(detailModal));
    supplierForm.addEventListener('submit', handleSave);

    supplierTableBody.addEventListener('click', async (e)=>{
      const btn = e.target.closest('button'); if(!btn) return;
      const id = btn.dataset.id;
      if(btn.classList.contains('detail-btn')) showDetails(id);
      else if(btn.classList.contains('edit-btn')){
        const res = await fetch(contextPath + '/Supplier?action=detail&id='+id);
        const data = await res.json();
        openFormModal(data.supplier);
      }else if(btn.classList.contains('toggle-status-btn')){
        toggleStatus(id, btn.dataset.action);
      }
    });

    reportFilterForm.addEventListener('submit', (e)=>{
      e.preventDefault();
      const fd = new FormData(reportFilterForm);
      showDetails(fd.get('id'), Object.fromEntries(fd));
    });

    document.addEventListener('keydown', (e)=>{
      if(e.key==='Escape'){ hideModal(formModal); hideModal(detailModal); }
    });

    // init
    loadSuppliers();
  });
  </script>
</body>
</html>
