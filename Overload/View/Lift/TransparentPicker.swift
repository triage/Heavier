//
//  PickerTransparent.swift
//  Overload
//
//  Created by Eric Schulte on 10/29/20.
//

import Foundation
import SwiftUI

final class TransparentPickerView: UIPickerView {
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews[1].isHidden = true
    }
}

/**
 iOS Picker class with the update bug which can cause the SwiftUI picker to reset.
 */
struct TransparentPicker<Content: View>: UIViewRepresentable {
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        @Binding var selection: Int
        
        var initialSelection: Int?
        var viewForRow: (Int) -> Content
        var rowCount: Int
        private let rowHeight: CGFloat = 50.0

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            rowCount
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return rowHeight
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.selection = row
        }
        
        func pickerView(
            _ pickerView: UIPickerView,
            viewForRow row: Int,
            forComponent component: Int, reusing view: UIView?) -> UIView {
            
            let hostingController = UIHostingController(rootView: viewForRow(row))
            return hostingController.view
        }
        
        init(selection: Binding<Int>, viewForRow: @escaping (Int) -> Content, rowCount: Int) {
            self.viewForRow = viewForRow
            self._selection = selection
            self.rowCount = rowCount
        }
    }
    
    @Binding var selection: Int
    
    var rowCount: Int
    let viewForRow: (Int) -> Content

    func makeCoordinator() -> TransparentPicker.Coordinator {
        return Coordinator(selection: $selection, viewForRow: viewForRow, rowCount: rowCount)
    }

    func makeUIView(context: UIViewRepresentableContext<TransparentPicker>) -> TransparentPickerView {
        let view = TransparentPickerView()
        view.delegate = context.coordinator
        view.dataSource = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: TransparentPickerView, context: UIViewRepresentableContext<TransparentPicker>) {
        
        context.coordinator.viewForRow = self.viewForRow
        context.coordinator.rowCount = rowCount
        uiView.selectRow(selection, inComponent: 0, animated: true)
    }
}

struct TransparentPicker_Previews: PreviewProvider {
    @State static var selection = 0
    static var previews: some View {
        TransparentPicker(selection: $selection, rowCount: 20) { (row) in
            Text("Row-\(row)")
        }
    }
}
