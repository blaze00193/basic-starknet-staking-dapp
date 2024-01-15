/* eslint-disable react/prop-types */
import { NavLink } from "react-router-dom";

function NavigationLink({ text, to }) {
  return (
    <li className="rounded-[20px] bg-transparent px-[20px] py-[10px]">
      <NavLink to={to}>{text}</NavLink>
      {/* {text} */}
    </li>
  );
}

export default NavigationLink;
