import { order_click } from "../order_click"

export const templateUpdateTrade = (item) => {
  const templateTransfer = () => {
  if (item.transfer == "green") {
    return `<div name="order_tranfer" id="item.transfer" class="green_circle"></div>`
  } else if (item.transfer == "red") {
    return `<div name="order_tranfer" id="item.transfer" class="red_circle"></div>`
  }
    return `<div name="order_tranfer" id="item.transfer" class="transition-all colors"></div>`
  }

  const templateStatus = () => {
  if (item.status == "success") {
    return `Принята`
  } else if (item.status == "fail") {
    return `Отклонено`
  }
  return `Активная`
  }

  const templateType = () => {
    if (item.item_order.type == "sale") {
      return `Продажa`
    } else if (item.item_order.type == "purchase") {
      return `Продажa`
    }
  }

  const inner = `
  <td class="px-6 2xl:px-2 py-2">
     ${templateType()} 
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200 break-words">
    ${item.updated_at}
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200 break-words">
     ${item.item_order.currency_short_name} 
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200 break-words">
     ${item.item_order.course_sale}
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200 break-words">
     ${item.volume}
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200 break-words">
    ${item.terms} 
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200 break-words">
    ${templateTransfer()}     
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200 break-words">
    ${item.item_order.filial_name} 
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200 break-words">
    ${templateStatus()}
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200">
    <button class="accept_delete_adopted_trade styles_none"
      data-map="<%= item |> PwHelper.Normalize.repo |> Jason.encode!() %>">
     <span class="material-symbols-outlined" style="color:red; font-weight: 900;">delete</span>
    </button>
  </td>
  `

  const template = `
  <tr class="order-click text-black" data-item='${JSON.stringify(item)}' identifier='${item.id}' style="background-color: ${item.color}">
  ${inner}
  </tr>
    `
    return {template: template, inner: inner, type: item.type};
}