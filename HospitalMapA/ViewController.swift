//
//  ViewController.swift
//  HospitalMapA
//
//  Created by 遠藤 直弥 on 2015/02/10.
//  Copyright (c) 2015年 Greenpeas Info. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var lm: CLLocationManager! = nil
    var longitude: CLLocationDegrees!  // 緯度を保持
    var latitude: CLLocationDegrees!  // 経度を保持

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // 1. 初期位置と表示範囲を設定して，画面に地図を表示する
        // .0 現在地を取得する
        lm = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        lm.delegate = self
        lm.requestAlwaysAuthorization()
        lm.startUpdatingLocation()
        
        // 2. オープンデータを読み込み，地図上にピンを打つ
        // http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/mapnavoskdat_iryou.csv
        // X,Y,施設名,施設名かな,施設名（施設名かな）,所在地,地区名,TEL,FAX,詳細情報,開館時間,URL,バリアフリー情報,駐輪場 PC,駐輪場 携,大分類,小分類,カテゴリ,アイコン番号,施設ID
        // .1 ファイルを読み込む（ファイルは事前にプロジェクトに追加しておく; 2015/02/01）
        let path: NSString = NSBundle.mainBundle().pathForResource("mapnavoskdat_iryou", ofType: "csv")!
        var lines: Array = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!.componentsSeparatedByString("\r\n")
        
        // .2 データを取り込む（施設名，Y=緯度，X=経度，TEL）
        var facilityNames: Array = [String]()
        var latitudeOfFacility: Dictionary = [String: CLLocationDegrees]()
        var longitudeOfFacility: Dictionary = [String: CLLocationDegrees]()
        var phoneNumberOfFacility: Dictionary = [String: String]()
        for line: String in lines {
            var dataOf: Array = line.componentsSeparatedByString(",")
            // 見出し行と空行は削除
            if (dataOf[0] == "X" || dataOf[0] == "") {
                continue
            }
            facilityNames.append(dataOf[2]); // 施設名
            latitudeOfFacility[dataOf[2]] = atof(dataOf[1]) as CLLocationDegrees; // 緯度
            longitudeOfFacility[dataOf[2]] = atof(dataOf[0]) as CLLocationDegrees; // 経度
            phoneNumberOfFacility[dataOf[2]] = dataOf[7]; // TEL
        }
        
        // .3 annotation（地図上のピン）を表示する
        for facilityName in facilityNames {
            var facilityAnnotation = MKPointAnnotation()
            facilityAnnotation.coordinate = CLLocationCoordinate2DMake(latitudeOfFacility[facilityName]!, longitudeOfFacility[facilityName]!)
            facilityAnnotation.title = facilityName
            facilityAnnotation.subtitle = phoneNumberOfFacility[facilityName]
            self.mapView.addAnnotation(facilityAnnotation)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 位置情報取得成功時
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        latitude = newLocation.coordinate.latitude
        longitude = newLocation.coordinate.longitude
        NSLog("latitude: \(latitude) , longitude: \(longitude)")

        // .1 初期位置を現在地に設定する
        var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        // .2 表示範囲を設定する
        let span = MKCoordinateSpanMake(0.05, 0.05)
        // .3 表示する中心位置と範囲を設定する
        var centerPosition = MKCoordinateRegionMake(centerCoordinate, span)
        // .4 地図を表示する
        mapView.setRegion(centerPosition, animated: true)
        // .5 位置情報の取得を終了する
        lm.stopUpdatingLocation()
    
    }

    // 位置情報取得失敗時
    func locationManager(manager: CLLocation, didFailWithError error: NSError) {
        NSLog("Error")

        // .1 初期位置を南森町駅 (34.697699,135.511078) に設定する
        var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        // .2 表示範囲を設定する
        let span = MKCoordinateSpanMake(0.05, 0.05)
        // .3 表示する中心位置と範囲を設定する
        var centerPosition = MKCoordinateRegionMake(centerCoordinate, span)
        // .4 地図を表示する
        mapView.setRegion(centerPosition, animated: true)
        // .5 位置情報の取得を終了する
        lm.stopUpdatingLocation()

    }

}

