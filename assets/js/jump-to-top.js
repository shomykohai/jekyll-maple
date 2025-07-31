document.addEventListener("DOMContentLoaded", function () {
    const jumpToTop = document.getElementById("jump-to-top");
    if (!jumpToTop) return;


    function getScrollableParent(el) {
        let parent = el.parentElement;
        while (parent) {
            const overflowY = window.getComputedStyle(parent).overflowY;
            if ((overflowY === 'auto' || overflowY === 'scroll') && parent.scrollHeight > parent.clientHeight) {
                return parent;
            }
            parent = parent.parentElement;
        }
        return window;
    }

    const scrollTarget = getScrollableParent(jumpToTop);

    function getScrollY() {
        return scrollTarget === window ? window.scrollY : scrollTarget.scrollTop;
    }

    function toggleJumpToTopVisibility() {
        if (getScrollY() > 200) {
            jumpToTop.classList.add("show");
        } else {
            jumpToTop.classList.remove("show");
        }
    }

    const eventTarget = scrollTarget === window ? window : scrollTarget;
    eventTarget.addEventListener("scroll", toggleJumpToTopVisibility);

    toggleJumpToTopVisibility();

    jumpToTop.addEventListener("click", () => {
        console.log("Jump to top clicked");
        scrollTarget.scrollTo({ top: 0, behavior: "smooth" });
    });
});
