/* eslint-disable react/prop-types */

function DataROw({ title, value }) {
  return (
    <div className="flex justify-between items-center text-sm font-medium text-[#3a3a3a]">
      <h3 className="text-black">{title}</h3>
      <h3>{value}</h3>
    </div>
  );
}

export default DataROw;
