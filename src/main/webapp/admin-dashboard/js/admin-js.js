/*
 * JavaScript cho Admin Panel
 * Xử lý menu sidebar
 */
document.addEventListener('DOMContentLoaded', function() {
    const treeviews = document.querySelectorAll('.sidebar-menu .treeview > a');
    treeviews.forEach(function(treeviewLink) {
        treeviewLink.addEventListener('click', function(e) {
            const parentLi = this.parentElement;
            if (parentLi.classList.contains('treeview')) {
                e.preventDefault();
                document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => {
                    if (li !== parentLi) {
                        li.classList.remove('menu-open');
                        li.classList.remove('active');
                    }
                });
                parentLi.classList.toggle('menu-open');
                parentLi.classList.toggle('active');
            }
        });
    });

    // Phần này cần các biến từ JSP, nên ta sẽ để lại trong JSP
    // const currentAction = "${requestScope.currentAction}";
    // const currentModule = "${requestScope.currentModule}";
    // ...
});