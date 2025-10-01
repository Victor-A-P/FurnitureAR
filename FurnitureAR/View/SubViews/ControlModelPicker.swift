import SwiftUI

struct ControlModelPicker: View
{
    @Binding var selectedControlMode: Int
    
    let controlModes = ControlModes.allCases
    
    //Para modificar la apariencia del picker
    init(selectedControlMode: Binding<Int>)
    {
        self._selectedControlMode = selectedControlMode
        UISegmentedControl.appearance().setTitleTextAttributes( [.foregroundColor:UIColor(displayP3Red: 1.0, green: 0.827, blue:0, alpha: 1) ], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes( [.foregroundColor:UIColor.white], for: .normal)
    }
    
    var body: some View
    {
        Picker(selection: $selectedControlMode, label: Text("Select a Control Mode"))
        {
            ForEach(0 ..< controlModes.count)
            { index in
                Text(self.controlModes[index].rawValue.uppercased()).tag(index)
            }
            
            /*
             
             ForEach(controlModes, id: \.self)
             { mode in
                 Text(mode.rawValue.capitalized)
                     .font(.title)
                     .fontWeight(.semibold)
                     .frame(minHeight: 55)
             }
             */
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 400)
        .glassEffect(.clear.tint(.black.opacity(0.425) ) )
        .padding(.horizontal,10)
        .padding(.bottom,20)
    }
}


