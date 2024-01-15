/* eslint-disable react/prop-types */
function FlexContainer({ gap, children }) {
  return (
    <div className={`flex items-center ${gap && "gap-x-".concat(`${gap}]`)}`}>
      {children}
    </div>
  );
}

export default FlexContainer;
