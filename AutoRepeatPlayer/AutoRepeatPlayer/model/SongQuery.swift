//
//  SongQuery.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 6. 4..
//  Copyright © 2017년 jmk. All rights reserved.
//

import Foundation
import MediaPlayer

struct SongInfo {
    
    var albumTitle: String?
    var artistName: String?
    var songTitle:  String
    var songURL : NSURL
    var artName : MPMediaItemArtwork?
    var songId   :  NSNumber
}


struct AlbumInfo {
    var albumTitle: String
    var albumArtist: String?
    var albumTrackCount: Int?
    
    var songs: [SongInfo]
}

class SongQuery {
    func get(songCategory: String) -> [AlbumInfo] {
        
        let albumsQuery: MPMediaQuery
        if songCategory == "Artist" {
            albumsQuery = MPMediaQuery.artists()
            let artistsItems: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
            return convertArtist(albumsItems: artistsItems)
        } else if songCategory == "Album" {
            albumsQuery = MPMediaQuery.albums()
            let albumsItems: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
            return convertAlbum(albumsItems: albumsItems)
        } else if songCategory == "Genres" {
            albumsQuery = MPMediaQuery.genres()
            let albumsItems: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
            return convertAlbum(albumsItems: albumsItems)
        } else if songCategory == "Playlist" {
            albumsQuery = MPMediaQuery.playlists()
            let playlists: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
            return convertPlaylist(albumsItems: playlists)
        }else {
            albumsQuery = MPMediaQuery.songs()
            let songsItems: [MPMediaItem] = albumsQuery.items! as [MPMediaItem]
            return convertSong(albumItems: songsItems)
        }
    }
    
    func getItem( songId: NSNumber ) -> MPMediaItem {
        
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: songId, forProperty: MPMediaItemPropertyPersistentID )
        
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate( property )
        
        var items: [MPMediaItem] = query.items! as [MPMediaItem]
        
        return items[items.count - 1]
        
    }

    private func convertArtist (albumsItems: [MPMediaItemCollection]) ->[AlbumInfo] {
        var albums: [AlbumInfo] = []
        for album in albumsItems {

            let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
            var songs: [SongInfo] = []
            var albumTitle: String = ""
            

            for song in albumItems {
                albumTitle = song.value( forProperty: MPMediaItemPropertyArtist ) as! String

                let songInfo: SongInfo = SongInfo(
                        albumTitle: song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as? String,
                        artistName: song.value( forProperty: MPMediaItemPropertyArtist ) as? String,
                        songTitle:  song.value( forProperty: MPMediaItemPropertyTitle ) as! String,
                        songURL: song.value( forProperty: MPMediaItemPropertyAssetURL ) as! NSURL,
                        artName: song.value( forProperty: MPMediaItemPropertyArtwork ) as? MPMediaItemArtwork,
                        songId:     song.value( forProperty: MPMediaItemPropertyPersistentID ) as! NSNumber
                )
                songs.append( songInfo )
            }
            
            let albumInfo: AlbumInfo = AlbumInfo(
                    albumTitle: albumTitle,
                    albumArtist: album.value( forProperty: MPMediaItemPropertyAlbumArtist ) as? String,
                    albumTrackCount: album.value( forProperty: MPMediaItemPropertyAlbumTrackCount ) as? Int,
//                    artwork: album.value( forProperty: MPMediaItemPropertyArtwork ) as? <#MPMediaItemArtwork?#>,

                    songs: songs
            )

            albums.append( albumInfo )
        }

        return albums
    }

    private func convertAlbum(albumsItems: [MPMediaItemCollection]) ->[AlbumInfo] {
        var albums: [AlbumInfo] = []
        for album in albumsItems {

            let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
            var songs: [SongInfo] = []
            var albumTitle: String = ""

            for song in albumItems {
                albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String

                let songInfo: SongInfo = SongInfo(
                        albumTitle: song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String,
                        artistName: song.value( forProperty: MPMediaItemPropertyArtist ) as? String,
                        songTitle:  song.value( forProperty: MPMediaItemPropertyTitle ) as! String,
                        songURL : song.value( forProperty: MPMediaItemPropertyAssetURL ) as! NSURL,
                        artName: song.value( forProperty: MPMediaItemPropertyArtwork ) as? MPMediaItemArtwork,
                        songId:     song.value( forProperty: MPMediaItemPropertyPersistentID ) as! NSNumber
                )
                songs.append( songInfo )
            }

            let albumInfo: AlbumInfo = AlbumInfo(
                    albumTitle: albumTitle,
                    albumArtist: album.value( forProperty: MPMediaItemPropertyAlbumArtist ) as? String,
                    albumTrackCount: album.value( forProperty: MPMediaItemPropertyAlbumTrackCount ) as? Int,
                    songs: songs
            )

            albums.append( albumInfo )
        }

        return albums
    }

    func convertPlaylist(albumsItems: [MPMediaItemCollection]) ->[AlbumInfo] {
        
        var albums: [AlbumInfo] = []
        for album in albumsItems {
            
            let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
            var songs: [SongInfo] = []
            var albumTitle: String = ""
            
            for song in albumItems {
                albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
                
                let songInfo: SongInfo = SongInfo(
                    albumTitle: song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String,
                    artistName: song.value( forProperty: MPMediaItemPropertyArtist ) as? String,
                    songTitle:  song.value( forProperty: MPMediaItemPropertyTitle ) as! String,
                    songURL : song.value( forProperty: MPMediaItemPropertyAssetURL ) as! NSURL,
                    artName: song.value( forProperty: MPMediaItemPropertyArtwork ) as? MPMediaItemArtwork,
                    songId:     song.value( forProperty: MPMediaItemPropertyPersistentID ) as! NSNumber
                )
                songs.append( songInfo )
            }
            
            let albumInfo: AlbumInfo = AlbumInfo(
                albumTitle: albumTitle,
                albumArtist: album.value( forProperty: MPMediaItemPropertyAlbumArtist ) as? String,
                albumTrackCount: album.value( forProperty: MPMediaItemPropertyAlbumTrackCount ) as? Int,

                songs: songs                )

            albums.append( albumInfo )
        }
        return albums
        
    }
    
    private func convertSong(albumItems: [MPMediaItem]) ->[AlbumInfo] {
        var albums: [AlbumInfo] = []
        var songs: [SongInfo] = []
        var albumTitle: String = ""

        for song in albumItems {
            albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
    
            let songInfo: SongInfo = SongInfo(
                albumTitle: song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String,
                artistName: song.value( forProperty: MPMediaItemPropertyArtist ) as? String,
                songTitle:  song.value( forProperty: MPMediaItemPropertyTitle ) as! String,
                songURL : song.value( forProperty: MPMediaItemPropertyAssetURL ) as! NSURL,
                artName: song.value( forProperty: MPMediaItemPropertyArtwork ) as? MPMediaItemArtwork,
                songId:     song.value( forProperty: MPMediaItemPropertyPersistentID ) as! NSNumber
            )
            songs.append( songInfo )
        }
    
        let albumInfo: AlbumInfo = AlbumInfo(
            albumTitle: albumTitle,
            albumArtist: nil,
            albumTrackCount: nil,

            songs: songs
        )
    
        albums.append( albumInfo )
    
        return albums
    }
}
