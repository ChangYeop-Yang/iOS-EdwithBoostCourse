//
//  DetailCountryViewController.swift
//  WeatherToday
//
//  Created by 양창엽 on 13/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class DetailCountryViewController: UIViewController {

    // MARK: - Variables
    private  var cityInformation:       [CityType]                      = Array<CityType>()
    internal var countryInformation:    (code: String, name: String)    = ("", "")
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var cityWeatherTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Set UITabelView DataSource and Delegate
        self.cityWeatherTableView.dataSource = self
        
        // MARK: Fetch Country JSON
        fetchCountryJSON(group: DispatchGroup())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set Navigation Controller
        self.navigationItem.titleView?.tintColor = .white
        self.navigationController?.view.tintColor = .white
        self.navigationItem.title = self.countryInformation.name
    }
    
    // MARK: - User Method
    private func fetchCountryJSON(group: DispatchGroup) {
        
        group.enter()
        DispatchQueue.global().async(group: group) { [weak self] in
            
            guard let code = self?.countryInformation.code, let dataAsset = NSDataAsset(name: code) else {
                group.leave()
                return
            }
            
            // MARK: Fetch Country JSON from Assets
            guard let datas: [CityType] = try? JSONDecoder().decode([CityType].self, from: dataAsset.data) else {
                group.leave()
                return
            }
            
            self?.cityInformation = datas
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.cityWeatherTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension DetailCountryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cityInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as? CityDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let inf = self.cityInformation[indexPath.row]
        cell.setCityWeatherInformation(name: inf.nameCity, temputuer: inf.celsius, rainFall: inf.rainfall, icon: inf.state)
        
        return cell
    }
}
