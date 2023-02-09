function input() {
   var input = [...document.querySelectorAll(".number_input_only")];
   input.forEach((el) => {
      el.addEventListener("input", (e) => {
         e.currentTarget.value = e.currentTarget.value.replace(/[^0-9.]/g, "");
      });
   });
}
input();