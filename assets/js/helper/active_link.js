const activeLink = [...document.querySelectorAll(".active-link")];
const path = window.location;
activeLink.forEach((e) => {
   if (e.href == path.href) {
      e.classList.add("active");
   }
});