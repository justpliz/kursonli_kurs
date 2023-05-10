document.addEventListener('DOMContentLoaded', () => {
  const elements = [...document.querySelectorAll("[data-id]")]
  function elementsMaxGreen() {
    x([...document.querySelectorAll(".item[data-select='1']")].map(x => x.querySelector(".buy")))
    x([...document.querySelectorAll(".item[data-select='2']")].map(x => x.querySelector(".buy")))
    x([...document.querySelectorAll(".item[data-select='3']")].map(x => x.querySelector(".buy")))
    function x(element) {
      const maxElement = element.reduce(
        (prev, current) => {
          let prevNumber = parseFloat(prev.innerText) || 0.0
          let currentNumber = parseFloat(current.innerText)
          if (isNaN(currentNumber)) {
            prev.classList.remove('best_course')
            current.classList.remove('best_course')
            return prev
          } else {
            prev.classList.remove('best_course')
            current.classList.remove('best_course')
            return prevNumber >= currentNumber ? prev : current
          }
        }
      );
      if (!isNaN(parseFloat(maxElement.innerText))) {
        maxElement.classList.add('best_course')
      }
    }
  }
  function elementsMinGreen() {
    x([...document.querySelectorAll(".item[data-select='1']")].map(x => x.querySelector(".sale")))
    x([...document.querySelectorAll(".item[data-select='2']")].map(x => x.querySelector(".sale")))
    x([...document.querySelectorAll(".item[data-select='3']")].map(x => x.querySelector(".sale")))
    function x(element) {
      const minElement = element.reduce(
        (prev, current) => {
          let prevNumber = parseFloat(prev.innerText) || 999999999
          let currentNumber = parseFloat(current.innerText)
          if (isNaN(currentNumber)) {
            prev.classList.remove('best_course')
            current.classList.remove('best_course')
            return prev
          } else {
            prev.classList.remove('best_course')
            current.classList.remove('best_course')
            return prevNumber <= currentNumber ? prev : current
          }
        }
      );
      if (minElement.innerText != "-") {
        minElement.classList.add('best_course')
      }
    }
  }
  elementsMaxGreen()
  elementsMinGreen()
  let courses = JSON.parse(document.querySelector(".courses").dataset.item).map(el => el.short_name)
  const selectTable = [...document.querySelectorAll(".select_table")]
  selectTable.forEach((el) => el.addEventListener('change', (e) => {
    const currentSelect = e.currentTarget.dataset.select
    const valueEl = e.currentTarget.value
    elements.forEach((value, index) => {
      const elemGiveData = value.querySelector(`.dataget[data-select="${currentSelect}"]`)
      const elemFindSale = elemGiveData.querySelector(`.sale`)
      const elemFindBuy = elemGiveData.querySelector(`.buy`)
      const item = JSON.parse(value.dataset.item)
      const find = item.course.find((el) => {
        return el.short_name
          == valueEl
      })
      if (find != undefined) {
        elemFindSale.innerHTML = find.sale
        elemFindBuy.innerHTML = find.buy
      }
      else {
        elemFindSale.innerHTML = "-"
        elemFindBuy.innerHTML = "-"
      }
    })
    elementsMaxGreen()
    elementsMinGreen()
  }));
  const sortButtonsSale = document.querySelectorAll('.sort_sale');
  sortButtonsSale.forEach(button => {
    button.addEventListener('click', () => {
      const tableRows = Array.from(document.querySelectorAll('.data-table tr'));
      const columnIndex = Array.from(button.parentNode.parentNode.parentNode.children).indexOf(button.parentNode.parentNode);
      tableRows.sort((row1, row2) => {
        const sale1Text = row1.children[columnIndex].querySelector('.sale').textContent.replace(',', '.');
        const sale2Text = row2.children[columnIndex].querySelector('.sale').textContent.replace(',', '.');
        if (sale1Text === '' && sale2Text === '') {
          return 0;
        } else if (sale1Text === '') {
          return button.classList.contains('sort-asc') ? 1 : -1;
        } else if (sale2Text === '') {
          return button.classList.contains('sort-asc') ? -1 : 1;
        }
        const sale1 = parseFloat(sale1Text);
        const sale2 = parseFloat(sale2Text);
        return button.classList.contains('sort-asc') ? sale1 - sale2 : sale2 - sale1;
      });
      tableRows.forEach(row => row.parentNode.removeChild(row));
      tableRows.forEach(row => {
        const saleSpan = row.children[columnIndex].querySelector('.sale');
        const existingArrows = saleSpan.querySelectorAll('.arrow');
        existingArrows.forEach(existingArrow => existingArrow.parentNode.removeChild(existingArrow));
        document.querySelector('.data-table').appendChild(row);
      });
      button.classList.toggle('sort-asc');
    });
  });
  const sortButtonsPur = document.querySelectorAll('.sort_buy');
  sortButtonsPur.forEach(button => {
    button.addEventListener('click', () => {
      const tableRows = Array.from(document.querySelectorAll('.data-table tr'));
      const columnIndex = Array.from(button.parentNode.parentNode.parentNode.children).indexOf(button.parentNode.parentNode);
      tableRows.sort((row1, row2) => {
        const buy1Text = row1.children[columnIndex].querySelector('.buy').textContent.replace(',', '.');
        const buy2Text = row2.children[columnIndex].querySelector('.buy').textContent.replace(',', '.');
        if (buy1Text === '' && buy2Text === '') {
          return 0;
        } else if (buy1Text === '') {
          return button.classList.contains('sort-asc') ? 1 : -1;
        } else if (buy2Text === '') {
          return button.classList.contains('sort-asc') ? -1 : 1;
        }
        const buy1 = parseFloat(buy1Text);
        const buy2 = parseFloat(buy2Text);
        return button.classList.contains('sort-asc') ? buy1 - buy2 : buy2 - buy1;
      });
      tableRows.forEach(row => row.parentNode.removeChild(row));
      tableRows.forEach(row => {
        const buySpan = row.children[columnIndex].querySelector('.buy');
        const existingArrows = buySpan.querySelectorAll('.arrow');
        existingArrows.forEach(existingArrow => existingArrow.parentNode.removeChild(existingArrow));
        document.querySelector('.data-table').appendChild(row);
      });
      button.classList.toggle('sort-asc');
    });
  });
});