//
//  MonthYearPickerViewController.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

public protocol MonthYearPickerDelegate: class {
    func select(month: (number: Int, name: String), year: Int)
}

/// Date picker variant without day of the month.
open class MonthYearPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    public enum RestrictSelection {
        case none
        case inTheFuture
        case inThePast
    }
    private var restrictSelection = RestrictSelection.none

    @IBOutlet weak private (set) var pickerView: UIPickerView!
    @IBOutlet weak private (set) var cancelButton: UIButton!
    @IBOutlet weak private (set) var doneButton: UIButton!
    private var pickerLabelsFont = UIFont.boldSystemFont(ofSize: 24)

    weak public var delegate: MonthYearPickerDelegate?
    private var months = [String]()
    private var years = [Int]()
    private var initialSelection: (month: Int, year: Int)?

    override open func viewDidLoad() {
        super.viewDidLoad()
        months = MonthYearPickerViewController.getMonthsOfTheYear()
        if years.isEmpty {
            years = getYears()
        }
        if self.initialSelection == nil {
            let now = Date()
            let currentMonth = Calendar.current.component(.month, from: now)
            let currentYear = Calendar.current.component(.year, from: now)
            initialSelection = (currentMonth - 1, currentYear)
        }

        pickerView.dataSource = self
        pickerView.delegate = self
        if let (month, year) = self.initialSelection {
            pickerView.selectRow(month, inComponent: 0, animated: false)
            if let yearIndex = years.firstIndex(of: year) {
                pickerView.selectRow(yearIndex, inComponent: 1, animated: false)
            }
        }
    }

    // MARK: -

    open func setYears(yearsInThePast: Int = 50, yearsInTheFuture: Int = 50) {
        years = getYears(yearsInThePast: yearsInThePast, yearsInTheFuture: yearsInTheFuture)
    }

    open func setInitialSelection(month: Int, year: Int) {
        initialSelection = (month - 1, year)
    }

    open func setRestriction(_ restriction: RestrictSelection) {
        self.restrictSelection = restriction
    }

    open func setPickerLabelsCustomFont(_ font: UIFont) {
        self.pickerLabelsFont = font
    }

    // MARK: - UIPickerViewDataSource

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return months.count
        } else {
            return years.count
        }
    }

    // MARK: - UIPickerViewDelegate

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel: UILabel
        if let label = view as? UILabel {
            pickerLabel = label
        } else {
            pickerLabel = UILabel()
            pickerLabel.font = self.pickerLabelsFont
            pickerLabel.textAlignment = .center
        }
        if component == 0 {
            pickerLabel.text = months[row]
        } else {
            pickerLabel.text = String(years[row])
        }
        return pickerLabel
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        checkRestrictSelection()
    }

    // MARK: -

    @IBAction private func cancelClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction private func doneClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        let monthIndex = pickerView.selectedRow(inComponent: 0)
        self.delegate?.select(month: (monthIndex + 1, months[monthIndex]), year: years[pickerView.selectedRow(inComponent: 1)])
    }

    public class func getMonthsOfTheYear() -> [String] {
        let dateFormatter = DateFormatter()
        var monthNames = [String]()
        for month in 0..<12 {
            monthNames.append(dateFormatter.monthSymbols[month])
        }
        return monthNames
    }

    private func getYears(yearsInThePast: Int = 50, yearsInTheFuture: Int = 50) -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return [Int]((currentYear - yearsInThePast)...(currentYear + yearsInTheFuture))
    }

    private func checkRestrictSelection() {
        if restrictSelection == .none {
            return
        }
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let selectedYear = years[pickerView.selectedRow(inComponent: 1)]
        if (restrictSelection == .inTheFuture && selectedYear < currentYear)
            || (restrictSelection == .inThePast && selectedYear > currentYear) {
            return
        }
        if selectedYear != currentYear,
            let yearIndex = years.firstIndex(of: currentYear) {
            pickerView.selectRow(yearIndex, inComponent: 1, animated: true)
        }
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let selectedMonth = pickerView.selectedRow(inComponent: 0) + 1
        if (restrictSelection == .inTheFuture && selectedMonth > currentMonth)
            || (restrictSelection == .inThePast && selectedMonth < currentMonth) {
            pickerView.selectRow(currentMonth - 1, inComponent: 0, animated: true)
        }
    }
}
