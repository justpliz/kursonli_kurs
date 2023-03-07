const btns = document.querySelectorAll(".tab-btn");
const contents = document.querySelectorAll(".tab-content");

btns.forEach((btn) => {
   btn.addEventListener("click", (e) => {
      const btnId = e.target.id;
      const contentId = btnId.replace("-btn", "-content");

      btns.forEach((btn) => {
         btn.classList.remove("active");
      });
      e.target.classList.add("active");

      contents.forEach((content) => {
         content.classList.remove("active");
      });
      document.getElementById(contentId).classList.add("active");

      localStorage.setItem("activeTabId", btnId);
   });
});

const activeTabId = localStorage.getItem("activeTabId");
if (activeTabId) {
   const activeTab = document.getElementById(activeTabId);
   if (activeTab) {
      activeTab.click();
   }
} else {
   btns[0].click();
}