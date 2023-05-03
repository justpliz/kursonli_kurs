function inputEng() {
   var input = [...document.querySelectorAll(".eng_text_only")];
   input.forEach((el) => {
      el.addEventListener("input", (e) => {
         e.currentTarget.value = e.currentTarget.value.replace(/[^a-zA-Z0-9\s.,!?_\-+=@#$%&/:;]/g, "");
      });
   });
}
inputEng();
