export const trigger = (el, etype, custom) => {
    const evt = custom ?? new Event( etype, { bubbles: true } );
    el.dispatchEvent( evt );
  };