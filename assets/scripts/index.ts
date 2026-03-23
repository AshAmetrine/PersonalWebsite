function codeToolbarHTML(code_block_id: string) : string {
  return `<div class="code-toolbar">
    <button class="copy-button" data-copy-id="${code_block_id}" title="Copy">
      <svg class="icon" aria-hidden="true" focusable="false">
        <use href="/icons.svg#icon-copy"></use>
      </svg>
    </button>
  </div>
  `;
}

function createCodeToolbars() {
  const code_blocks = document.querySelectorAll("pre > code");
  for (let i = 0; i < code_blocks.length; i++) {
    const code_block = code_blocks[i];

    const pre_block = code_block.parentElement;
    if (pre_block.parentElement?.classList.contains("code-container")) continue;

    if (code_block.id.length == 0) {
      code_block.id = "codeblock#" + i;
    }

    const container = document.createElement("div");
    container.className = "code-container";

    pre_block.parentElement?.insertBefore(container, pre_block);
    container.insertAdjacentHTML("afterbegin", codeToolbarHTML(code_block.id));
    container.appendChild(pre_block);
  }
}

function copy(el: HTMLElement) {
  const copy_container_id = el.getAttribute("data-copy-id");
  var content: string | null;
  if (copy_container_id) {
    const copy_container = document.getElementById(copy_container_id);
    content = (copy_container && copy_container.textContent);
  } else {
    // Fallback to copying button text content
    content = el.textContent;
  }

  if (content) {
    navigator.clipboard.writeText(content.trim());

    // Display tooltip
    displayTooltip(el, "Copied text");
  } else {
    console.error("No text found to copy")
  }
}

function displayTooltip(attached_el: HTMLElement, message: string) {
  const current_tooltips = document.getElementsByClassName("tooltip");
  if (current_tooltips.length > 0) return;

  const tooltip = document.createElement("div");
  tooltip.className = "tooltip";
  tooltip.textContent = message;

  document.body.appendChild(tooltip);
  const tooltip_rect = tooltip.getBoundingClientRect();

  const attach_rect = attached_el.getBoundingClientRect();
  let left = attach_rect.left + window.scrollX;
  const top = attach_rect.top + window.scrollY - tooltip_rect.height;
  if (left + tooltip_rect.width > window.outerWidth) {
    left = window.outerWidth - tooltip_rect.width;
  }
  tooltip.style.top = `${top}px`;
  tooltip.style.left = `${left}px`;

  setTimeout(() => {
    tooltip.style.opacity = "0";

    setTimeout(() => {
      tooltip.remove();
    }, 400);
  }, 400);
}

document.addEventListener("DOMContentLoaded", () => {
  createCodeToolbars();

  // Register Copy Button Listeners
  const copy_buttons = document.getElementsByClassName("copy-button");

  for (var i = 0; i < copy_buttons.length; i++) {
    copy_buttons[i].addEventListener("click", function(e) {
      copy(e.currentTarget as HTMLElement);
    });
  }
});
