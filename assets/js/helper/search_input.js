let inputs = document.getElementsByClassName("search-input");

for (let i = 0; i < inputs.length; i++) {
  inputs[i].addEventListener("input", searchTables);
}

function searchTables() {
  let inputValue = this.value;
  let tables = document.getElementsByClassName("data-table");

  for (let i = 0; i < tables.length; i++) {
    let table = tables[i];

    for (let j = 0; j < table.rows.length; j++) {
      let row = table.rows[j];
      let containsValue = false;

      for (let k = 0; k < row.cells.length; k++) {
        let cell = row.cells[k];

        if (
          cell.innerHTML.toLowerCase().indexOf(inputValue.toLowerCase()) > -1
        ) {
          containsValue = true;
          break;
        }
      }

      if (!containsValue) {
        row.style.display = "none";
      } else {
        row.style.display = "";
      }
    }
  }
}
