//
//  CalendarView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/05.
//

import SwiftUI

struct ContributionCalendarView: View {
    struct Cell: View {
        var size: CGSize
        var value: ContribCalendarCell

        var body: some View {
            RoundedRectangle(cornerSize: CGSize(width: size.width / 4, height: size.height / 4))
                .fill(fillColor)
                .stroke(strokeColor)
                .frame(width: size.width, height: size.height)
        }
    
        var fillColor: Color {
            guard value.cellType != .blank else { return Color(.clear) }
            switch value.score {
            case 1...3:
                return Color(UIColor(displayP3Red: 155/255, green: 233/255, blue: 168/255, alpha: 1.0))
            case 4...6:
                return Color(UIColor(displayP3Red: 64/255, green: 196/255, blue: 99/255, alpha: 1.0))
            case 6...7:
                return Color(UIColor(displayP3Red: 48/255, green: 161/255, blue: 78/255, alpha: 1.0))
            case 8...10:
                return Color(UIColor(displayP3Red: 33/255, green: 110/255, blue: 57/255, alpha: 1.0))
            default:
                return Color(UIColor.tertiarySystemGroupedBackground)
            }
        }
    
        var strokeColor: Color {
            guard value.cellType != .blank else { return Color(.clear) }
            switch value.cellType {
            case .today:
                return Color(.red)
            default:
                return Color(.quaternaryLabel)
            }
        }
    }

    var size: CGSize = CGSize(width: 16, height: 16)
    var value: ContribCalendar

    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 4) {
                Spacer().frame(height: 20)
                ForEach(Weekday.values, id: \.self) {
                    Text($0.shortTitle)
                        .font(.footnote)
                        .frame(width: size.width, height: size.height)
                }
                Spacer()
            }
            ScrollViewReader { scrollView in
                ScrollView([.horizontal], showsIndicators: true) {
                    HStack(spacing: 4) {
                        ForEach(value.headers, id: \.self) {
                            Text($0.title).frame(
                                width: 16 * CGFloat($0.length) + 4 * CGFloat($0.length - 1),
                                alignment: .leading
                            ).font(.footnote)
                        }
                        Spacer()
                    }.padding([.leading], 16)
                    Grid(alignment: .topLeading, horizontalSpacing: 4, verticalSpacing: 4) {
                        ForEach(value.rows, id: \.self) { row in
                            GridRow {
                                ForEach(row.cells, id: \.self) {
                                    Cell(size: size, value: $0)
                                }
                            }
                        }
                    }.padding(EdgeInsets(top: 0, leading: 4, bottom: 16, trailing: 0))
                }.onAppear {
                    scrollView.scrollTo(value.today, anchor: .center)
                }
            }
        }.padding([.top], 16)
    }
}

#Preview {
    ContributionCalendarView(value: ContribCalendar(date: Date()))
}
