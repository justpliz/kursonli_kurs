window.Modalka = Swal.mixin({
   scrollbarPadding: false,
   heightAuto: false,
   customClass: {
      container: 'font_app',
   },
   willOpen: (toast) => {
      var input = [...document.querySelectorAll('.number_input_only')];
      input.forEach((el) => {
         el.addEventListener("input", (e) => {
            e.currentTarget.value = e.currentTarget.value.replace(/[^0-9.]/g, '');
         })
      });
      var multipleCancelButton = new Choices('#choices-multiple', {
         removeItemButton: true,
      });
      let phoneInputs = document.querySelectorAll('input[data-tel]');
      let getInputNumbersValue = function (input) {
         // Return stripped input value — just numbers
         return input.value.replace(/\D/g, '');
      }
      let onPhonePaste = function (e) {
         let input = e.target,
            inputNumbersValue = getInputNumbersValue(input);
         let pasted = e.clipboardData || window.clipboardData;
         if (pasted) {
            let pastedText = pasted.getData('Text');
            if (/\D/g.test(pastedText)) {
               // Attempt to paste non-numeric symbol — remove all non-numeric symbols,
               // formatting will be in onPhoneInput handler
               input.value = inputNumbersValue;
               return;
            }
         }
      }
      let onPhoneInput = function (e) {
         let input = e.target,
            inputNumbersValue = getInputNumbersValue(input),
            selectionStart = input.selectionStart,
            formattedInputValue = "";
         if (!inputNumbersValue) {
            return input.value = "";
         }
         if (input.value.length != selectionStart) {
            // Editing in the middle of input, not last symbol
            if (e.data && /\D/g.test(e.data)) {
               // Attempt to input non-numeric symbol
               input.value = inputNumbersValue;
            }
            return;
         }
         if (["7", "8", "9"].indexOf(inputNumbersValue[0]) > -1) {
            if (inputNumbersValue[0] == "9") inputNumbersValue = "7" + inputNumbersValue;
            let firstSymbols = (inputNumbersValue[0] == "8") ? "8" : "+7";
            formattedInputValue = input.value = firstSymbols + " ";
            if (inputNumbersValue.length > 1) {
               formattedInputValue += '(' + inputNumbersValue.substring(1, 4);
            }
            if (inputNumbersValue.length >= 5) {
               formattedInputValue += ') ' + inputNumbersValue.substring(4, 7);
            }
            if (inputNumbersValue.length >= 8) {
               formattedInputValue += '-' + inputNumbersValue.substring(7, 9);
            }
            if (inputNumbersValue.length >= 10) {
               formattedInputValue += '-' + inputNumbersValue.substring(9, 11);
            }
         } else {
            formattedInputValue = '+' + inputNumbersValue.substring(0, 16);
         }
         input.value = formattedInputValue;
      }
      let onPhoneKeyDown = function (e) {
         let inputValue = e.target.value.replace(/\D/g, '');
         if (e.keyCode == 8 && inputValue.length == 1) {
            e.target.value = "";
         }
      }
      for (let phoneInput of phoneInputs) {
         phoneInput.addEventListener('keydown', onPhoneKeyDown);
         phoneInput.addEventListener('input', onPhoneInput, false);
         phoneInput.addEventListener('paste', onPhonePaste, false);
      }
      let inputs = document.getElementsByClassName("bit_input");
      for (let i = 0; i < inputs.length; i++) {
         inputs[i].addEventListener("input", function () {
            let numString = this.value.replace(/\D/g, "");
            let parts = numString.split(/(?=(?:\d{3})+$)/);
            this.value = parts.join(" ");
         });
      }
   }
})