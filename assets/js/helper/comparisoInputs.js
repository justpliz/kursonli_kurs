import toast from "./toast";

export function comparisoInputs(oneInput, twoInput) {
  oneInput.addEventListener("input", handleInput);
  twoInput.addEventListener("input", handleInput);

  function handleInput() {
    this.value = this.value.replace(/[^0-9.]/g, "");
    const valueOne = parseInt(oneInput.value.replace(/\s/, "") || 0);
    const valueTwo = parseInt(twoInput.value.replace(/\s/, "") || 0);

    if (valueOne <= valueTwo) {
      twoInput.value = valueOne;
    }
  }
}
