//
//  Pokemon.swift
//  pokedex
//
//  Created by wyatt on 04/05/16.
//  Copyright © 2016 com.smoked. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defence: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvoTxt: String!
    private var _nextEvoId: String!
    private var _nextEvoLvl: String!
    private var _pokemonURL: String!
    
    var name: String {
        return tidy(_name)
    }
    var pokedexId: Int {
        return _pokedexId
    }
    var description: String {
        return tidy(_description)
    }
    var type: String {
        return tidy(_type)
    }
    var defence: String {
        return tidy(_defence)
    }
    var height: String {
        return tidy(_height)
    }
    var weight: String {
        return tidy(_weight)
    }
    var attack: String {
        return tidy(_attack)
    }
    var nextEvoTxt: String {
        return tidy(_nextEvoTxt)
    }
    var nextEvoId: String {
        return tidy(_nextEvoId)
    }
    var nextEvoLvl: String {
        return tidy(_nextEvoLvl)
    }
    
    init(name: String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId
        
        _pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId)/"
    }
    
    func tidy(sStr: String?) -> String {
        if sStr == nil {return ""}
        return "\(sStr!)"
    }
    
    func downloadPokemonDetails(completionHandler: DownloadComplete) {
        
        let nsurlPokemon = NSURL(string: _pokemonURL)!
        Alamofire.request(.GET, nsurlPokemon).responseJSON { responsePokemon in
            
            let resultPokemon = responsePokemon.result
            
            if let asDictPokemon = resultPokemon.value as? Dictionary<String, AnyObject> {
                if let weight = asDictPokemon["weight"] as? String {
                    self._weight = weight
                    
                }
                if let height = asDictPokemon["height"] as? String {
                    self._height = height
                    
                }
                if let attack = asDictPokemon["attack"] as? Int {
                    self._attack = "\(attack)"
                    
                }
                if let defence = asDictPokemon["defense"] as? Int {
                    self._defence = "\(defence)"
                    
                }
                if let types = asDictPokemon["types"] as? [Dictionary<String, String>] where types.count > 0  {
                    
                    if let name = types[0]["name"] {
                        self._type = name
                    }
                    if types.count > 1 {
                        for var x = 1; x < types.count; x++ {
                            if let name = types [x]["name"] {
                                self._type! += "/\(name.capitalizedString)"
                            }
                        }
                    }
                } else {
                    self._type = ""
                }
                print(self._type)
                if let asDictDesc = asDictPokemon["descriptions"] as? [Dictionary<String, String>] where asDictDesc.count > 0  {
                    
                    if let uriDesc = asDictDesc[0]["resource_uri"] {
                        
                        let nsurlDesc = NSURL(string:"\(URL_BASE)\(uriDesc)")!
                        
                        Alamofire.request(.GET, nsurlDesc).responseJSON { responseDesc in
                            
                            let resultDesc = responseDesc.result
                            
                            if let asDictDesc = resultDesc.value as? Dictionary<String, AnyObject> {
                        
                                if let desc = asDictDesc["description"] as? String {
                                    self._description = desc
                                    print(self._description)
                                }
                            }
                            completionHandler()
                        }
                    }
                } else {
                    
                    self._description = ""
                    
                }
                
                if let asEvos = asDictPokemon["evolutions"] as? [Dictionary<String, AnyObject>] where asEvos.count > 0  {
                    
                    if let evoTo = asEvos[0]["to"] as? String {
                        
                        // not supporing mega pokemon right now, although api does have the data
                        if evoTo.rangeOfString("mega") == nil {
                           
                            if let sEvoURI = asEvos[0]["resource_uri"] as? String  {
                                
                                let sEvoURIParsed = sEvoURI.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString: "")
                                
                                let sEvoNum = sEvoURIParsed.stringByReplacingOccurrencesOfString("/", withString: "")
                                
                                self._nextEvoId = sEvoNum
                                self._nextEvoTxt = evoTo
                                if let iLvl = asEvos[0]["level"] as? Int {
                                    self._nextEvoLvl = "\(iLvl)"
                                }
                                
                                
                                print( self._nextEvoId)
                                print( self._nextEvoTxt )
                                print( self._nextEvoLvl )
                                
                            }
                            
                        }
                        
                    }
                    

                }
                

//              print(self._type)
//              print(self._weight)
//              print(self._height)
//              print(self._attack)
//              print(self._defence)
            }
        }
    }
}






