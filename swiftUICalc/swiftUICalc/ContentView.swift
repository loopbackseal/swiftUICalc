//
//  ContentView.swift
//  swiftUICalc
//
//  Created by Young Soo Hwang on 2022/01/27.
//

import SwiftUI

enum CalculatorButton: String {
    
    case zero, one, two, three, four, five, six, seven, eight, nine, decimal
    case equals, plus, minus, multiply, divide
    case ac, plusMinus, percent
    
    var title: String {
        switch self {
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .plus: return "+"
        case .minus: return "-"
        case .multiply: return "X"
        case .divide: return "/"
        case .plusMinus: return "+/-"
        case .percent: return "%"
        case .equals: return "="
        case .decimal: return "."
        default: return "AC"
        }
    }
    
    var background: Color {
        switch self {
        case .ac, .plusMinus, .percent:
            return Color(.lightGray)
        case .plus, .minus, .multiply, .divide, .equals:
            return Color(.darkGray)
        default:
            return Color("green")
        }
    }
    
}

// MARK: Env Objects
// I can treat this as the Global Application State

class GlobalEnvironment: ObservableObject {

    @Published var display = "0"
    @Published var expression: [String] = []
    @Published var wasOperator: Int = 0
    
    func receiveInput(calculatorButton: CalculatorButton) {
        switch calculatorButton {
        case .ac, .plusMinus, .percent:
            if calculatorButton == .percent {
                let tmp = (self.display as NSString).floatValue
                self.display = String(tmp / 100)
            } else if calculatorButton == .plusMinus {
                let start = self.display.startIndex
                let end = self.display.endIndex
                if self.display[start] == "-" {
                    let newStart = self.display.index(start, offsetBy: 1)
                    self.display = String(self.display[newStart ..< end])
                } else {
                    self.display = "-" + self.display
                }
            } else {
                expression = []
                self.display = "0"
            }
        case .plus, .minus, .multiply, .divide, .equals:
            wasOperator = 1
            if calculatorButton == .equals {
                calcInput()
            } else {
                if expression.count == 2 {
                    calcInput()
                }
                expression.append(self.display)
                expression.append(calculatorButton.title)
            }
        default:
            if self.display != "0" && self.display != "오류" && wasOperator == 0 {
                self.display = self.display + calculatorButton.title
            } else {
                wasOperator = 0
                self.display = calculatorButton.title
            }
        }
    }
    
// MARK: Calculate Inputs by expression
    func calcInput() {
        if expression.count == 2 {
            switch expression.popLast() {
            case "-":
                if let first = expression.popLast() {
                    guard let a = Decimal(string: first) else { return }
                    guard let b = Decimal(string: self.display) else { return }
                    self.display = NSDecimalNumber(decimal: a - b).stringValue
                }
            case "X":
                if let first = expression.popLast() {
                    guard let a = Decimal(string: first) else { return }
                    guard let b = Decimal(string: self.display) else { return }
                    self.display = NSDecimalNumber(decimal: a * b).stringValue
                }
            case "/":
                if let first = expression.popLast() {
                    if self.display == "0" {
                        self.display = "오류"
                    } else {
                        guard let a = Decimal(string: first) else { return }
                        guard let b = Decimal(string: self.display) else { return }
                        self.display = NSDecimalNumber(decimal: a / b).stringValue
                    }
                }
            default:
                if let first = expression.popLast() {
                    guard let a = Decimal(string: first) else { return }
                    guard let b = Decimal(string: self.display) else { return }
                    self.display = NSDecimalNumber(decimal: a + b).stringValue
                }
            }
        }
    }
    
    func deleteDisplay() {
        let start = self.display.startIndex
        let end = self.display.index(start, offsetBy: -1)
        self.display = String(self.display[start ..< end])
    }
    
}

// MARK: View
struct ContentView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    
    let buttons: [[CalculatorButton]]  = [
        [.ac, .plusMinus, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .decimal, .equals]
    ]
    var body: some View {
        
        ZStack (alignment: .bottom){
            Color.black.edgesIgnoringSafeArea(.all)
                .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                            .onEnded { value in
                                let horizontalAmount = value.translation.width as CGFloat
                                if horizontalAmount > 0 {
                                    if env.display.count > 1 {
                                        let start = env.display.startIndex
                                        let end = env.display.index(start, offsetBy: env.display.count - 1)
                                        env.display = String(env.display[start ..< end])
                                    } else {
                                        env.display = "0"
                                    }
                                }
                            })
            VStack (spacing: 14) {
                HStack {
                    Spacer()
                    Text(env.display).foregroundColor(.white)
                        .fontWeight(.thin)
                        .font(.system(size: 90))
                }
                .padding(.trailing, 15)
                ForEach(buttons, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { button in
                            CalculatorButtonView(button: button)
                        }
                    }
                }
            }
            .padding(.bottom, 45)
            .padding(.trailing, 10)
        }
    }

}

struct CalculatorButtonView: View {
    
    var button: CalculatorButton
    
    @EnvironmentObject var env: GlobalEnvironment
    
    var body: some View {
        Button(action: {
            self.env.receiveInput(calculatorButton: button)
        }) {
        Text(button.title)
            .font(.system(size: 35))
            .multilineTextAlignment(.leading)
            .frame(width: self.buttonWidth(button), height: (UIScreen.main.bounds.width - 5 * 16) / 4)
                .foregroundColor(.white)
                .background(button.background)
                .cornerRadius(35)
        }
        .padding(.leading, 8)
    }
    
    private func buttonWidth(_ button: CalculatorButton) -> CGFloat {
        if button == .zero {
            return (UIScreen.main.bounds.width - 4 * 16) / 4 * 2 + 12
        }
        return (UIScreen.main.bounds.width - 5 * 16) / 4
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GlobalEnvironment()).previewInterfaceOrientation(.portrait)
    }
}
