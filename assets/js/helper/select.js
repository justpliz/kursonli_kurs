const select = document.querySelector(".custom-select");
const selectTrigger = select.querySelector(".select-header");
const options = select.querySelector(".select-options");
const optionItems = select.querySelectorAll(".select-options a");
const selectedOption = localStorage.getItem("selectedOption");

if (selectedOption) {
  select.querySelector(".selected-option").textContent = selectedOption;
}

selectTrigger.addEventListener("click", function () {
  select.classList.toggle("open");
  options.classList.toggle("open");
});

optionItems.forEach(function (option) {
  option.addEventListener("click", function () {
    const selectedOption = option.textContent;
    select.querySelector(".selected-option").textContent = selectedOption;
    select.classList.remove("open");
    options.classList.remove("open");

    localStorage.setItem("selectedOption", selectedOption);
  });
});

document.addEventListener("click", function (e) {
  if (!select.contains(e.target)) {
    select.classList.remove("open");
    options.classList.remove("open");
  }
});