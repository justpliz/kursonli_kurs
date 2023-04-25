const numberInputs = document.querySelectorAll('.number');
numberInputs.forEach(function (e) {
  let previousValue = '';
  e.addEventListener('input', () => {
    const currentValue = e.value;
    if (currentValue === '' || currentValue === '.' || currentValue === ',' || /^\d+(,\d{0,3})?(\.\d{0,3})?$/.test(currentValue)) {
      previousValue = currentValue;
    } else {
      e.value = previousValue;
    }
  });
});


const elementTd = Array.from(document.querySelectorAll(".td-item"));

elementTd.forEach((el) => {
  const valueForPurchaseInput = el.querySelector(".value_for_purchase");
  const valueForSaleInput = el.querySelector(".value_for_sale");

  differenceInputs(valueForSaleInput, valueForPurchaseInput);
});

const buttonSubmit = document.querySelector("#submit-btn");
let inputsArray = Array.from(document.querySelectorAll('input'));
let isValid = true;

function differenceInputs(oneInput, twoInput) {
  oneInput.addEventListener("input", handleInput);
  twoInput.addEventListener("input", handleInput);

  function handleInput() {
    let valueOne = parseFloat(oneInput.value.replace(/\s/, "").replace(",", ".") || 0);
    let valueTwo = parseFloat(twoInput.value.replace(/\s/, "").replace(",", ".") || 0);

    let isOneInputError = false;
    let isTwoInputError = false;

    if (isNaN(valueOne) || !(/^\d+(,\d{0,3})?(\.\d{0,3})?$/.test(oneInput.value))) {
      oneInput.style.border = "1px solid red";
      isOneInputError = true;
    } else {
      oneInput.style.border = "";
    }

    if (isNaN(valueTwo) || !(/^\d+(,\d{0,3})?(\.\d{0,3})?$/.test(twoInput.value))) {
      twoInput.style.border = "1px solid red";
      isTwoInputError = true;
    } else {
      twoInput.style.border = "";
    }

    if (isOneInputError || isTwoInputError) {
      buttonSubmit.disabled = true;
      return;
    }

    const lastCharIndexOne = oneInput.value.length - 1;
    const isLastCharDotOne = oneInput.value[lastCharIndexOne] === "." || oneInput.value[lastCharIndexOne] === ",";

    if (isLastCharDotOne && lastCharIndexOne > 0) {
      oneInput.style.border = "1px solid red";
      buttonSubmit.disabled = true;
      return;
    }

    const lastCharIndexTwo = twoInput.value.length - 1;
    const isLastCharDotTwo = twoInput.value[lastCharIndexTwo] === "." || twoInput.value[lastCharIndexTwo] === ",";

    if (isLastCharDotTwo && lastCharIndexTwo > 0) {
      twoInput.style.border = "1px solid red";
      buttonSubmit.disabled = true;
      return;
    }

    if (valueOne < valueTwo) {
      twoInput.style.border = "1px solid red";
      buttonSubmit.disabled = true;
    } else {
      oneInput.style.border = "";
      twoInput.style.border = "";
      inputsArray = Array.from(document.querySelectorAll('input'));
      const borderColorsArray = inputsArray.map(input => input.style.borderColor === "" ? true : false);
      isValid = borderColorsArray.every(value => value === true);

      if (isValid) {
        oneInput.style.border = "";
        twoInput.style.border = "";
        buttonSubmit.disabled = false;
      }
    }
  }
}
