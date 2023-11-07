//
//  TajweedParser.swift
//  TajweedParser
//
//  Created by Fitra Bayu on 05/11/23.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
public struct TajweedColors: View {
    var text:String
    var metaColor:MetaColor = MetaColor()
    var font = Font.custom("Kitab-Regular",size: 24)
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        let string = text.utf8EncodedString()
        let textsAyah = parse(rawAyah: string,metaColor: metaColor)
        TextTajweedColors(textAyah: textsAyah,i: 0).font(font)
    }
}

extension String {
    func utf8DecodedString()-> String {
        let data = self.data(using: .utf8)
        let message = String(data: data!, encoding: .nonLossyASCII) ?? ""
        return message
    }
    
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8) ?? ""
        return text
    }
}

@available(iOS 13.0, *)
public func TajweedColorText( text:String, metaColor:MetaColor = MetaColor()) -> Text{
    let string = text.utf8EncodedString()
    let textsAyah = parse(rawAyah: string,metaColor: metaColor)
    return TextTajweedColors(textAyah: textsAyah,i: 0)
}

public struct TajweedAyah:Identifiable{
    public var id:Int
    var color:String
    var text:String
}

public struct MetaColor{

    //hamza-wasl, silent, laam-shamsiyah
    var hsl: String = "#000000"

    //Normal Prolongation: 2 Vowels
    var madda_normal: String = "#537FFF"

    //Permissible Prolongation: 2, 4, 6 Vowels
    var madda_permissible: String = "#4050FF"

    //Necessary Prolongation: 6 Vowels
    var madda_necesssary: String = "#000EBC"

    //Obligatory Prolongation: 4-5 Vowels
    var madda_obligatory: String = "#2144C1"

    //Qalaqah
    var qalaqah: String = "#DD0008"

    //Ikhafa' Shafawi - With Meem
    var ikhafa_shafawi: String = "#D500B7"

    //Ikhafa'
    var ikhafa: String = "#9400A8"

    //Idgham Shafawi - With Meem
    var idgham_shafawi: String = "#58B800"

    //Iqlab
    var iqlab: String = "#26BFFD"

    //Idgham - With Ghunnah
    var idgham_with_ghunnah: String = "#169777"

    //Idgham - Without Ghunnah
    var idgham_without_ghunnah: String = "#169200"

    //Idgham - Mutajanisayn
    var idgham_mutajanisayn: String = "#A1A1A1"
    
    //Idgham - Mutaqaribayn
    var idgham_mutaqaribayn: String = "#A1A1A1"

    //Ghunnah: 2 Vowels
    var ghunnah: String = "#FF7E1E"
    
    public init(hsl:String="#000000",
                madda_normal:String = "#537FFF",
                madda_permissible: String = "#4050FF",
                madda_necesssary: String = "#000EBC",
                madda_obligatory: String = "#2144C1",
                qalaqah: String = "#DD0008",
                ikhafa_shafawi: String = "#D500B7",
                ikhafa: String = "#9400A8",
                idgham_shafawi: String = "#58B800",
                iqlab: String = "#26BFFD",
                idgham_with_ghunnah: String = "#169777",
                idgham_without_ghunnah: String = "#169200",
                idgham_mutajanisayn: String = "#A1A1A1",
                idgham_mutaqaribayn: String = "#A1A1A1",
                ghunnah: String = "#FF7E1E") {
        self.hsl = hsl
        self.madda_normal = madda_normal
        self.madda_permissible = madda_permissible
        self.madda_necesssary = madda_necesssary
        self.madda_obligatory = madda_obligatory
        self.qalaqah = qalaqah
        self.ikhafa_shafawi = ikhafa_shafawi
        self.ikhafa = ikhafa
        self.idgham_shafawi = idgham_shafawi
        self.iqlab = iqlab
        self.idgham_with_ghunnah = idgham_with_ghunnah
        self.idgham_without_ghunnah = idgham_without_ghunnah
        self.idgham_mutajanisayn = idgham_mutajanisayn
        self.idgham_mutaqaribayn = idgham_mutaqaribayn
        self.ghunnah = ghunnah
    }
}

public func parse(rawAyah: String,metaColor:MetaColor) -> [TajweedAyah]{
    var datas = [TajweedAyah]()
    let tajweedMetas = "hslnpmqocfwiaudbg"
    print("rawayah \(rawAyah) ")
    
    
    var splits = [String]()
    var prev = ""
    var curr = ""
    var temp = ""
    var index = 0
    let aryChar = Array(rawAyah)
    while index < aryChar.count {
        curr = String(aryChar[index])
        if prev == "[" && tajweedMetas.contains(curr){
            splits.append(temp.utf8DecodedString())
            splits.append(curr)
            temp = ""
            while curr != "[" && index < aryChar.count {
                index += 1
                curr = String(aryChar[index])
            }
        }else if prev == "]"{
            splits.append(temp.utf8DecodedString())
            temp = ""
        }else if prev != "[" {
            temp.append(prev)
        }
        prev = curr
        index += 1
    }
    if prev != "]" {
        temp.append(prev)
    }
    splits.append(temp.utf8DecodedString())
    
    var metaSpilt:String = ""
    var i:Int = 0
    for ayahSpilt in splits {
        print("ayahSpilt \(ayahSpilt)")
        if tajweedMetas.contains(ayahSpilt){
            metaSpilt = ayahSpilt
        }else if(!metaSpilt.isEmpty){
            let metaColor = metaToColor(meta:metaSpilt.first!,metaColor: metaColor)
            
            datas.append(TajweedAyah(id:i, color: metaColor, text: ayahSpilt))
            metaSpilt = ""
            i+=1
        }else{
            datas.append(TajweedAyah(id:i, color: "#000000", text: ayahSpilt))
            i+=1
        }
    }
    return datas
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

@available(iOS 13.0, *)
private func TextTajweedColors(textAyah: [TajweedAyah],i:Int) -> Text {
    if i<textAyah.count-1 {
        return Text(textAyah[i].text).foregroundColor(Color(UIColor.fromHexString(hex: textAyah[i].color))) + TextTajweedColors(textAyah: textAyah,i:i+1)
    }else{
        return Text(textAyah[i].text).foregroundColor(Color(UIColor.fromHexString(hex: textAyah[i].color)))
    }
}

private func metaToColor(meta: Character,metaColor:MetaColor)-> String {
    var color: String = "#000000"
    switch(meta) {
        case "h":
        color = metaColor.hsl //hsl
        case "l":
            color = metaColor.hsl //hsl
        case "s":
            color = metaColor.hsl //hsl
        case "n" :
            color = metaColor.madda_normal
        case "p" :
        color = metaColor.madda_permissible
        case "m" :
        color = metaColor.madda_necesssary
        case "q" :
        color = metaColor.qalaqah
        case "o" :
        color = metaColor.madda_obligatory
        case "c" :
        color = metaColor.ikhafa_shafawi
        case "f" :
        color = metaColor.ikhafa
        case "w" :
        color = metaColor.idgham_shafawi
        case "i" :
        color = metaColor.iqlab
        case "a" :
        color = metaColor.idgham_with_ghunnah
        case "u" :
        color = metaColor.idgham_without_ghunnah
        case "d" :
        color = metaColor.idgham_mutajanisayn
        case "b" :
        color = metaColor.idgham_mutaqaribayn
        case "g" :
        color = metaColor.ghunnah
    default :
        color = "#000000"
    }
    return color
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(red: Int, green: Int, blue: Int, alpha:CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static func fromHexString(hex:String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    @available(iOS 13.0.0, *)
    static var previews: some View {
        TajweedColors(text:"بِسْمِ [h:1[ٱ]للَّهِ [h:2[ٱ][l[ل]رَّحْمَ[n[ـٰ]نِ [h:3[ٱ][l[ل]رَّح[p[ِي]مِ")
    }
}
