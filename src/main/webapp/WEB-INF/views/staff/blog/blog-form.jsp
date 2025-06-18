<%-- 
    Document   : blog-form
    Created on : Jun 14, 2025, 5:52:11 AM
    Author     : Lenovo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Add New Article</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" rel="stylesheet">

        <style>
            /* Reset CSS */
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            /* Body & Overall Layout */
            body {
                font-family: 'Poppins', sans-serif;
                background: #f0f2f5; /* Light gray background */
                color: #333;
                line-height: 1.6;
            }

            .main-wrapper {
                display: flex;
                justify-content: center;
                padding: 20px;
            }

            .page-content-wrapper {
                display: flex;
                gap: 20px;
                width: 100%;
                max-width: 1200px; /* Adjust as needed */
            }

            .left-panel {
                flex: 3; /* Takes more space */
                background-color: #ffffff;
                padding: 25px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
            }

            .right-panel {
                flex: 1; /* Takes less space */
                background-color: #ffffff;
                padding: 25px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
                display: flex;
                flex-direction: column;
                gap: 20px; /* Space between sections */
            }

            .header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
                padding-bottom: 15px;
                border-bottom: 1px solid #eee;
            }

            .header-title {
                font-size: 1.5rem;
                font-weight: 600;
                color: #2c3e50;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .header-actions {
                display: flex;
                gap: 10px;
            }

            .btn-action {
                padding: 8px 15px;
                border-radius: 6px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.2s ease;
                display: inline-flex;
                align-items: center;
                gap: 5px;
                text-decoration: none; /* Ensure buttons don't have underline from anchor styles */
            }

            .btn-cancel {
                background-color: #f0f2f5;
                color: #555;
                border: 1px solid #dcdcdc;
            }

            .btn-cancel:hover {
                background-color: #e2e4e8;
                border-color: #c0c0c0;
            }

            .btn-save {
                background-color: #007bff;
                color: white;
                border: none;
            }

            .btn-save:hover {
                background-color: #0056b3;
            }

            /* Form Group Styling */
            .form-section {
                margin-bottom: 45px;
            }

            .form-section-title {
                font-size: 1.1rem;
                font-weight: 600;
                color: #333;
                margin-bottom: 15px;
                padding-bottom: 10px;
                border-bottom: 1px solid #eee;
            }

            .form-group {
                margin-bottom: 20px;
            }

            .form-label {
                font-weight: 500;
                margin-bottom: 8px;
                display: block;
                color: #555;
                font-size: 0.95rem;
            }

            .form-control,
            .form-select {
                border-radius: 6px;
                padding: 10px 12px;
                border: 1px solid #dcdcdc;
                width: 100%;
                font-size: 0.95rem;
                transition: border-color 0.2s ease, box-shadow 0.2s ease;
            }

            .form-control:focus,
            .form-select:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
                outline: none;
            }

            /* Image Upload Section */
            .image-upload-section .form-label {
                margin-bottom: 10px;
            }

            .image-upload-area {
                border: 2px dashed #dcdcdc;
                border-radius: 8px;
                padding: 20px;
                text-align: center;
                color: #777;
                cursor: pointer;
                transition: all 0.2s ease;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
            }

            .image-upload-area:hover, .image-upload-area.drag-over {
                border-color: #007bff;
                background-color: #f7f7f7;
            }

            .upload-icon {
                font-size: 40px;
                color: #007bff;
                margin-bottom: 10px;
            }

            .upload-text {
                font-size: 0.9rem;
                margin-bottom: 10px;
            }

            .upload-buttons {
                display: flex;
                gap: 10px;
                justify-content: center;
                flex-wrap: wrap;
            }

            .btn-upload-url, .btn-upload-device {
                display: inline-flex;
                align-items: center;
                gap: 5px;
                padding: 8px 15px;
                border-radius: 6px;
                font-weight: 500;
                cursor: pointer;
                font-size: 0.9rem;
                transition: all 0.2s ease;
                text-decoration: none; /* Ensure buttons don't have underline from anchor styles */
            }

            .btn-upload-url {
                background-color: #e0f2ff;
                border: 1px solid #a7d9fd;
                color: #007bff;
            }

            .btn-upload-url:hover {
                background-color: #cce9ff;
                border-color: #007bff;
            }

            .btn-upload-device {
                background-color: #e0f2ff;
                border: 1px solid #a7d9fd;
                color: #007bff;
            }

            .btn-upload-device:hover {
                background-color: #cce9ff;
                border-color: #007bff;
            }

            /* Image Preview Section - adjusted for new layout */
            #imagePreviewContainer {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
                margin-top: 15px;
                padding: 10px;
                border: 1px solid #eee; /* Added a light border */
                border-radius: 6px;
                min-height: 80px; /* Minimum height for better appearance */
                align-items: center; /* Center items vertically if they are small */
                background-color: #fdfdfd;
            }

            .image-preview-item {
                position: relative;
                border: 1px solid #dcdcdc;
                border-radius: 6px;
                overflow: hidden;
                box-shadow: 0 1px 5px rgba(0, 0, 0, 0.05);
                transition: transform 0.1s ease;
            }

            .image-preview-item:hover {
                transform: translateY(-1px);
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            }

            .image-preview-item img {
                width: 100px; /* Adjust thumbnail size */
                height: 70px;
                object-fit: cover;
                display: block;
            }

            .image-preview-item .remove-btn {
                position: absolute;
                top: 3px;
                right: 3px;
                background-color: #dc3545;
                color: #fff;
                border: none;
                border-radius: 50%;
                width: 20px;
                height: 20px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 14px;
                cursor: pointer;
                opacity: 0.9;
                transition: all 0.2s ease;
                z-index: 10;
            }

            .image-preview-item .remove-btn:hover {
                background-color: #c82333;
                opacity: 1;
                transform: scale(1.1);
            }

            /* Status and Layout Selection */
            .radio-group label {
                display: flex;
                align-items: center;
                margin-bottom: 10px;
                cursor: pointer;
                font-size: 0.95rem;
                color: #555;
            }

            .radio-group input[type="radio"] {
                margin-right: 8px;
                width: 16px;
                height: 16px;
                accent-color: #007bff; /* Custom color for radio button */
            }

            .radio-group .status-label {
                font-weight: 500;
                color: #333;
            }

            .text-link {
                color: #007bff;
                text-decoration: none;
                font-size: 0.9rem;
                transition: color 0.2s ease;
            }

            .text-link:hover {
                color: #0056b3;
                text-decoration: underline;
            }

            .meta-description-preview {
                background-color: #f8f9fa;
                border: 1px solid #e9ecef;
                border-radius: 6px;
                padding: 15px;
                font-size: 0.9rem;
                color: #666;
                margin-top: 15px;
            }

            .meta-description-preview p {
                margin-bottom: 5px;
            }

            .meta-description-preview .title-preview {
                color: #1a0dab; /* Google search result title color */
                font-size: 1.1rem;
                font-weight: 500;
            }

            .meta-description-preview .url-preview {
                color: #006621; /* Google search result URL color */
                word-wrap: break-word;
            }

            .meta-description-preview .desc-preview {
                color: #545454;
            }

            /* Responsive Adjustments */
            @media (max-width: 992px) {
                .page-content-wrapper {
                    flex-direction: column;
                }
                .left-panel, .right-panel {
                    flex: none; /* Remove flex sizing */
                    width: 100%; /* Take full width */
                }
                .right-panel {
                    order: -1; /* Move right panel to the top on smaller screens */
                }
                .header-title {
                    font-size: 1.3rem;
                }
                .btn-action {
                    padding: 7px 12px;
                    font-size: 0.9rem;
                }
            }

            @media (max-width: 768px) {
                .main-wrapper {
                    padding: 15px;
                }
                .left-panel, .right-panel {
                    padding: 20px;
                }
                .header-title {
                    font-size: 1.2rem;
                }
                .form-section-title {
                    font-size: 1rem;
                }
                .form-label, .form-control, .form-select {
                    font-size: 0.9rem;
                }
                .upload-icon {
                    font-size: 36px;
                }
                .upload-text {
                    font-size: 0.85rem;
                }
                .btn-upload-url, .btn-upload-device {
                    padding: 6px 12px;
                    font-size: 0.85rem;
                }
                .image-preview-item img {
                    width: 80px;
                    height: 60px;
                }
                .image-preview-item .remove-btn {
                    width: 18px;
                    height: 18px;
                    font-size: 12px;
                }
            }

            @media (max-width: 576px) {
                .header {
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 10px;
                }
                .header-actions {
                    width: 100%;
                    justify-content: space-between;
                }
                .header-title {
                    margin-bottom: 10px;
                }
            }

        </style>
    </head>
    <!-- Updated Article Form Matching StaffBlogController -->
    <body>
        <div class="main-wrapper">
            <form action="${pageContext.request.contextPath}/StaffBlogController" method="post" enctype="multipart/form-data" class="page-content-wrapper">
                <div class="left-panel">
                    <div class="header">
                        <div class="header-title">
                            Add New Blog
                        </div>
                        <div class="header-actions">
                            <button type="button" class="btn-action btn-cancel">Cancel</button>
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
                            <label><input type="radio" name="status" value="published" checked><span class="status-label">Visible</span></label>
                            <label><input type="radio" name="status" value="draft"><span class="status-label">Hidden</span></label>
                            <label><input type="radio" name="status" value="scheduled"><span class="status-label">Schedule Visibility</span></label>
                        </div>
                    </div>

                    <div class="form-section">
                        <div class="form-section-title">Article Thumbnail</div>
                        <div id="dropZone" class="image-upload-area">
                            <span class="material-icons upload-icon">Image_upload</span>
                            <div class="upload-text">Drag & drop images here or</div>
                            <div class="upload-buttons">
                                <button type="button" class="btn-upload-url" id="uploadUrlBtn">
                                    <span class="material-icons">link</span> Add from URL
                                </button>
                                <label for="customFile1" class="btn-upload-device d-flex align-items-center gap-2">
                                    Choose image
                                    <input type="file" class="d-none" id="customFile1" name="thumbnailUrl" accept="image/*" />
                                </label>
                            </div>
                        </div>
                        <div id="imagePreviewContainer"></div>
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

                    <input type="hidden" name="staffId" value="1" />
                </div>
            </form>
        </div>

        <script>

            let selectedFiles = []; // Array to hold File objects chosen by the user

            const fileInput = document.getElementById('customFile1');
            const container = document.getElementById('imagePreviewContainer');
            const dropZone = document.getElementById('dropZone');

            // Event listener for when files are selected via button click (for "Upload from Device")
            fileInput.addEventListener('change', function (event) {
                addFilesToSelected(event.target.files);
                fileInput.value = ''; // Clear the file input to allow selecting the same files again
            });

            // Delegating click from a button to the hidden file input
            document.getElementById('uploadDeviceBtn').addEventListener('click', function () {
                fileInput.click();
            });

            // Handle "Add from URL" button (for future implementation)
            document.getElementById('uploadUrlBtn').addEventListener('click', function () {
                // Here you would implement logic to prompt for a URL and add it to previews
                alert('Adding images from URL will be developed later.');
            });

            // --- Drag & Drop functionality ---
            ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                dropZone.addEventListener(eventName, preventDefaults, false);
            });

            function preventDefaults(e) {
                e.preventDefault();
                e.stopPropagation();
            }

            // Highlight drop zone when dragging over
            ['dragenter', 'dragover'].forEach(eventName => {
                dropZone.addEventListener(eventName, () => dropZone.classList.add('drag-over'), false);
            });

            ['dragleave', 'drop'].forEach(eventName => {
                dropZone.addEventListener(eventName, () => dropZone.classList.remove('drag-over'), false);
            });

            // Handle dropped files
            dropZone.addEventListener('drop', handleDrop, false);

            function handleDrop(e) {
                const dt = e.dataTransfer;
                const files = dt.files;
                addFilesToSelected(files);
            }

            function addFilesToSelected(files) {
                const newFiles = Array.from(files).filter(file => file.type.startsWith('image/'));
                newFiles.forEach(file => {
                    // Check for duplicates before adding (simple check by name and size)
                    if (!selectedFiles.some(existingFile => existingFile.name === file.name && existingFile.size === file.size)) {
                        selectedFiles.push(file);
                    }
                });
                renderPreview();
            }

            // Function to render/re-render the image previews
            function renderPreview() {
                container.innerHTML = ''; // Clear existing previews first

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
                            renderPreview(); // Re-render the previews to update the display
                        };

                        wrapper.appendChild(img);
                        wrapper.appendChild(removeBtn);
                        container.appendChild(wrapper);
                    };

                    reader.readAsDataURL(file);
                });
            }

            // Handle form submission: Crucial for sending JavaScript-managed files
            document.querySelector('form').addEventListener('submit', function (event) {
                // TinyMCE content needs to be saved to the textarea first
                tinymce.triggerSave();

                // Create a new DataTransfer object to hold files from selectedFiles array
                const dataTransfer = new DataTransfer();
                selectedFiles.forEach(file => {
                    dataTransfer.items.add(file);
                });
                // Assign the files to the file input element.
                // This makes the files available to the backend as part of the form submission.
                fileInput.files = dataTransfer.files;
                // Ensure the name is correct for your backend to receive the files
                fileInput.name = "thumbnailFiles";
            })

            // Set current datetime for 'Published At' if it's not set
            document.addEventListener('DOMContentLoaded', function () {
                const publishedAtInput = document.getElementById('publishedAt');
                if (publishedAtInput && !publishedAtInput.value) { // Check if element exists before trying to set value
                    const now = new Date();
                    now.setMinutes(now.getMinutes() - now.getTimezoneOffset()); // Adjust for timezone to get local time
                    publishedAtInput.value = now.toISOString().slice(0, 16);
                }
            });

        </script>
    </body>
</html>