const activeLink = [...document.querySelectorAll(".active-link")];
const path = decodeURIComponent(window.location.href.replace(/\?.*$/, ""));
activeLink.forEach((e) => {
   if (decodeURIComponent(e.href) === path) {
      e.classList.add("active");
   }
});
