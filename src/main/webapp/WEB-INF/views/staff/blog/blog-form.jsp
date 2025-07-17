<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Add New Article</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/blog-form.css">
    </head>
    <body>
        <c:set var="currentAction" value="dashboard" scope="request"/>
        <c:set var="currentModule" value="admin" scope="request"/>
        <c:set var="pageTitle" value="Admin Dashboard" scope="request"/>

        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>

        <div class="main-wrapper">
            <form id="blogForm" action="${pageContext.request.contextPath}/StaffBlogController" method="post"
                  enctype="multipart/form-data" class="page-content-wrapper">

                <div class="left-panel">
                    <div class="header">
                        <div class="header-title">Add New Blog</div>
                        <div class="header-actions">
                            <button type="button" class="btn-action btn-cancel" onclick="resetForm()">Cancel</button>
                            <button type="submit" class="btn-action btn-save">Upload</button>
                        </div>
                    </div>

                    <div class="form-section">
                        <div class="form-section-title">Article Information</div>

                        <div class="form-group">
                            <label for="title" class="form-label">Title*</label>
                            <input type="text" name="title" class="form-control" id="title" placeholder="Enter title" required>
                        </div>

                        <div class="form-group">
                            <label for="slug" class="form-label">Slug</label>
                            <input type="text" name="slug" class="form-control" id="slug" placeholder="Enter slug">
                        </div>

                        <div class="form-group">
                            <label for="excerpt" class="form-label">Excerpt</label>
                            <textarea name="excerpt" id="excerpt" class="form-control" rows="2" placeholder="Short description..."></textarea>
                        </div>

                        <div class="form-group">
                            <label for="content" class="form-label">Article Content</label>
                            <textarea class="form-control" id="content" name="content" rows="5" placeholder="Enter content" required></textarea>
                        </div>

                        <div class="form-group">
                            <label for="tags" class="form-label">Tags</label>
                            <input type="text" name="tags" class="form-control" id="tags" placeholder="e.g., fashion, trends">
                        </div>
                    </div>
                </div>

                <div class="right-panel">
                    <div class="form-section">
                        <div class="form-section-title">Status</div>
                        <div class="radio-group">
                            <label><input type="radio" name="status" value="Published" checked> <span class="status-label">Visible</span></label>
                            <label><input type="radio" name="status" value="Draft"> <span class="status-label">Hidden</span></label>
                            <label><input type="radio" name="status" value="Archived"> <span class="status-label">Archived</span></label>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Upload Images</label>
                        <input type="file" id="imageInput" multiple accept="image/*" class="form-control" onchange="previewImages(event)">
                        <div id="imagePreviewContainer" class="image-preview-container"></div>
                    </div>

                    <div class="form-section">
                        <div class="form-section-title">Article Category</div>
                        <select class="form-select" name="category" id="category" required>
                            <option value="" selected disabled>Select article category</option>
                            <option value="Fashion">Fashion</option>
                            <option value="Style Tips">Style Tips</option>
                            <option value="News">News</option>
                        </select>
                    </div>
                </div>
            </form>
        </div>

        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script>
                            function resetForm() {
                                document.getElementById('blogForm').reset();
                                document.getElementById('imagePreviewContainer').innerHTML = "";
                                selectedFiles = [];
                            }

                            let selectedFiles = [];
                            const fileInput = document.getElementById('customFile1');
                            const container = document.getElementById('imagePreviewContainer');
                            const dropZone = document.getElementById('dropZone');

                            fileInput.addEventListener('change', function (event) {
                                addFilesToSelected(event.target.files);
                                fileInput.value = '';
                            });

                            document.querySelector('label[for="customFile1"]').addEventListener('click', function () {
                                fileInput.click();
                            });

                            document.getElementById('uploadUrlBtn').addEventListener('click', function () {
                                alert('Adding images from URL will be developed later.');
                            });

                            ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                                dropZone.addEventListener(eventName, preventDefaults, false);
                            });

                            function preventDefaults(e) {
                                e.preventDefault();
                                e.stopPropagation();
                            }

                            ['dragenter', 'dragover'].forEach(eventName => {
                                dropZone.classList.add('drag-over');
                            });

                            ['dragleave', 'drop'].forEach(eventName => {
                                dropZone.classList.remove('drag-over');
                            });

                            dropZone.addEventListener('drop', handleDrop, false);

                            function handleDrop(e) {
                                const dt = e.dataTransfer;
                                const files = dt.files;
                                addFilesToSelected(files);
                            }

                            function addFilesToSelected(files) {
                                const newFiles = Array.from(files).filter(file => file.type.startsWith('image/'));
                                newFiles.forEach(file => {
                                    if (!selectedFiles.some(existingFile => existingFile.name === file.name && existingFile.size === file.size)) {
                                        selectedFiles.push(file);
                                    }
                                });
                                renderPreview();
                            }

                            function renderPreview() {
                                container.innerHTML = '';
                                selectedFiles.forEach((file, index) => {
                                    const reader = new FileReader();
                                    reader.onload = function (e) {
                                        const wrapper = document.createElement('div');
                                        wrapper.classList.add('image-preview-item');

                                        const img = document.createElement('img');
                                        img.src = e.target.result;
                                        img.alt = "Preview";

                                        const removeBtn = document.createElement('button');
                                        removeBtn.innerHTML = '&times;';
                                        removeBtn.type = 'button';
                                        removeBtn.classList.add('remove-btn');
                                        removeBtn.title = 'Remove image';

                                        removeBtn.onclick = () => {
                                            selectedFiles = selectedFiles.filter((_, i) => i !== index);
                                            renderPreview();
                                        };

                                        wrapper.appendChild(img);
                                        wrapper.appendChild(removeBtn);
                                        container.appendChild(wrapper);
                                    };
                                    reader.readAsDataURL(file);
                                });
                            }

                            document.querySelector('form').addEventListener('submit', function (event) {
                                if (typeof tinymce !== 'undefined') {
                                    tinymce.triggerSave();
                                }

                                const dataTransfer = new DataTransfer();
                                selectedFiles.forEach(file => {
                                    dataTransfer.items.add(file);
                                });

                                fileInput.files = dataTransfer.files;
                            });
                            function previewImages(event) {
                                const files = event.target.files;
                                const previewContainer = document.getElementById('imagePreviewContainer');
                                previewContainer.innerHTML = ''; // clear old previews

                                Array.from(files).forEach((file, index) => {
                                    const reader = new FileReader();

                                    reader.onload = function (e) {
                                        const wrapper = document.createElement('div');
                                        wrapper.className = 'image-preview-item';

                                        const img = document.createElement('img');
                                        img.src = e.target.result;

                                        const btn = document.createElement('button');
                                        btn.className = 'remove-btn';
                                        btn.innerHTML = '&times;';
                                        btn.onclick = function () {
                                            wrapper.remove();
                                        };

                                        wrapper.appendChild(img);
                                        wrapper.appendChild(btn);
                                        previewContainer.appendChild(wrapper);
                                    };

                                    reader.readAsDataURL(file);
                                });
                            }
        </script>
    </body>
</html>
