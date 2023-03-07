const elHref = document.querySelectorAll(".lang_redirect")
Array.from(elHref).forEach((e) => {
  if (e.dataset.lang == localStorage.getItem("lang"))
    e.classList.add("active_redirect")
  else if (e.dataset.lang == "rus" && localStorage.getItem("lang") == undefined)
    e.classList.add("active_redirect")
  e.addEventListener("click", (event) => {
    localStorage.setItem("lang", event.target.dataset.lang)
  })
  e.href = e.href + "/?redirect_path=" + window.location.pathname + "?" + window.location.search.substr(1)
})
