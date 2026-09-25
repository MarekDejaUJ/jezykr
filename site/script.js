(function () {
  "use strict";

  function copyWithTextArea(text) {
    var field = document.createElement("textarea");
    field.value = text;
    field.setAttribute("readonly", "");
    field.style.position = "fixed";
    field.style.left = "-9999px";
    document.body.appendChild(field);
    field.select();
    field.setSelectionRange(0, field.value.length);

    var copied = document.execCommand("copy");
    document.body.removeChild(field);
    return copied;
  }

  async function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) {
      try {
        await navigator.clipboard.writeText(text);
        return true;
      } catch (error) {
        return copyWithTextArea(text);
      }
    }
    return copyWithTextArea(text);
  }

  function addCopyButtons() {
    document.querySelectorAll("pre code").forEach(function (code) {
      var pre = code.closest("pre");
      if (!pre || pre.querySelector(".copy-code")) return;

      var button = document.createElement("button");
      button.type = "button";
      button.className = "copy-code";
      button.textContent = "Kopiuj";
      button.setAttribute("aria-label", "Kopiuj zawartość bloku do schowka");

      button.addEventListener("click", async function () {
        var copied = await copyText(code.textContent);
        button.textContent = copied ? "Skopiowano" : "Zaznacz i skopiuj";
        window.setTimeout(function () { button.textContent = "Kopiuj"; }, 2000);
      });

      pre.appendChild(button);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", addCopyButtons);
  } else {
    addCopyButtons();
  }
})();
