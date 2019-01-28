# transferring files to/from cloud storage
# 01/27/19

require 'net/http'
# do we still need net/http if we're using httparty instead?
require 'httparty'

def print_help()
	# script usage message
	puts "Transfer files securely to/from local to dropbox!"
	puts "Usage: ruby dropbox_transfer.rb <direction flag> <src> <dst>"
	puts "\t<direction flag> must be either -u (upload to dropbox) or -d (download from dropbox)"
	puts "\t<src> is the file you want to move; NOTE: cannot move files greater than 350GB"
	puts "\t<dst> is the desired destination of the file"
end

def parse_inputs()
	# checks user inputs for completeness
	# returns [src, dst, dir] on success
	# returns 'false' on failure
	if ARGV.length == 1 && ARGV[0] == "-h"
		print_help()
		return false
	end
	if ARGV.length < 3
		puts "error: missing arguments"
		print_help()
		return false
	end
	dir = nil
	params = []
	ARGV.each do |arg|
		if arg == "-u" || arg == "-d"
			if dir != nil
				dir = arg[1]
			else
				puts "error: can only specify one direction '-u' or '-d'"
				print_help()
				return false
			end
		else
			# we only accept src and dst as other parameters
			if params.length < 2
				params.push(arg)
			else 
				puts "error: invalid arguments"
				print_help()
				return false
			end
		end
	end
	if dir == nil || params.length != 2 
		puts "error: missing argument"
		print_help()
		return false 
	end
	params.push(dir)
	return params
end

# call out to dropbox
def upload(src, dst)
	# src: the file to be transferred 
	# dst: the location to transfer the file to 
	# function that will upload a file to a dropbox location
	# returns a boolean indicating if it succeeded

	# A single request should not upload more than 150 MB. 
	# The maximum size of a file one can upload to an upload session is 350 GB.

	# check if src is greater than 350 GB
	if "file size" > 350gb
		puts "error: local file is too large to upload"
		return false
	end

	# start an upload session
	base_url = "https://content.dropboxapi.com/2/files/upload_session/"
	start_endpoint = "start"
	start_uri = URI(base_url+start_endpoint)
	start_uri.query = URI.encode_www_form()
	response = Net::HTTP.get_response(start_uri)
	session_id = nil
	# upload file
	upload_endpoint = "append_v2"
	upload_uri = URI(base_url+upload_endpoint)
	upload_uri.query = URI.encode_www_form()
	close = false
	while "unsent data" > 0 do 
		if "unsent data" < 150mb
			close = true
		end
		# send data here
	end
end

def download(src, dst)
	# src: the file to be transferred 
	# dst: the location to transfer the file to 

end

def transfer_files()
	inputs = parse_inputs()
	if !inputs
		return nil
	end
	if inputs[2] == "u"
		if !File.file(inputs[0])
			puts "error: unable to find local source file"
			return nil 
		end
		if !"dst directory exists"
			puts "error: remote destination does not exist"
			return nil 
		end
		upload(inputs[0], inputs[1])
	else 	# we're trying to download a file
		if !File.directory?(inputs[1])
			puts "error: local destination does not exist"
			return nil
		end
		if !"src file exists"
			puts "error: remote file does not exist" 
			return nil
		end 
		download(inputs[0], inputs[1])
	end
end