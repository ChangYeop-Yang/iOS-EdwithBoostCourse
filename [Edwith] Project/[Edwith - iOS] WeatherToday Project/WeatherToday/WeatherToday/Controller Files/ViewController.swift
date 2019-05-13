//
//  ViewController.swift
//  WeatherToday
//
//  Created by 양창엽 on 13/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Outlet Variables
    @IBOutlet private weak var countryWeatherTableView: UITableView!
    
    // MARK: - Variables
    private let CELL_IDENTIFIER:    String          = "BasicCell"
    private var countryInformation: [CountryType]   = Array<CountryType>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // MARK: Set UITabelView DataSource and Delegate
        self.countryWeatherTableView.delegate   = self
        self.countryWeatherTableView.dataSource = self
        
        // MARK: Fetch Country JSON
        fetchCountryJSON(group: DispatchGroup())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let nextViewController = segue.destination as? DetailCountryViewController else {
            return
        }
        
        guard let indexPath = self.countryWeatherTableView.indexPathForSelectedRow else {
            return
        }
        
        nextViewController.countryInformation.code = self.countryInformation[indexPath.row].nameAssert
        nextViewController.countryInformation.name = self.countryInformation[indexPath.row].nameKorean
    }
    
    // MARK: - User Method
    private func fetchCountryJSON(group: DispatchGroup) {
        
        group.enter()
        DispatchQueue.global().async(group: group) { [weak self] in
            
            guard let dataAsset: NSDataAsset = NSDataAsset(name: DataAssetName.Country.rawValue) else {
                group.leave()
                return
            }
            
            // MARK: Fetch Country JSON from Assets
            guard let datas: [CountryType] = try? JSONDecoder().decode([CountryType].self, from: dataAsset.data) else {
                group.leave()
                return
            }
            
            self?.countryInformation = datas
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.countryWeatherTableView.reloadData()
        }
    }
}

// MARK: - Extension UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
}

// MARK: - Extension UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countryInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.CELL_IDENTIFIER, for: indexPath)
        cell.textLabel?.text = self.countryInformation[indexPath.row].nameKorean
        
        DispatchQueue.main.async {
            let imageFileName = "flag_\(self.countryInformation[indexPath.row].nameAssert)"
            cell.imageView?.image = UIImage(named: imageFileName)
        }
        
        return cell
    }
}
