package haxevx.vuex.core;

#if macro
import haxe.macro.TypeTools;
import haxe.macro.Expr.Field;
import haxe.io.Path;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Expr;
import haxe.io.Bytes;
import sys.io.Process;
import haxe.ds.StringMap;
import haxe.macro.ComplexTypeTools;
import haxe.macro.MacroStringTools;


/**
 * note: this shouldn't be in .core package actually. The implementation here is particularly specific with gulp task dependency.
 * @author Glidias
 */
class VCSS
{
	static var CACHE_FOLDER_NAME:String = "processing-styles";
	static var MODULE_FOLDER_NAME:String = "processing-modules";
	
	public static function jsonModule(path : String, fileName:String) {
		var value = sys.io.File.getContent(path);
		var json = haxe.Json.parse(value);
		EXPORTS.set(fileName,  "."+json._ns);
		return json;
	}
	
	public static function jsonModuleExpr(path:String, fileName:String) {
		var result = jsonModule(path, fileName);
		return macro $v{result};
	}

	static var EXPORTS:StringMap<String>  = {
		#if !skipSASSExports
		Context.onAfterGenerate( function():Void {  // generate _exports.scss by default as a partial that can be used elsewhere
			
			var workingDirectory:String = Sys.getCwd();
			var moduleDir:String =  workingDirectory + MODULE_FOLDER_NAME+"/";
			if (!FileSystem.exists(moduleDir)) {
				return;
			}
				
			var exportStream:String = "";
			for (k in EXPORTS.keys()) {
				exportStream += "@import '" + k +"';\n";
				exportStream += "$" + k.substr(1) + ":'" + EXPORTS.get(k) +"';\n";
			}
				
			File.saveContent( moduleDir + "_exports.scss", exportStream );
		});
		#end
		new StringMap<String>();
	};
	
	/**
	 * 
	 * @param	filePath	(Optional) File path without file extension. If left null, empty, or undefined, will use current class package folder and filename.
	 * @param	fileExtension	File extension to use (eg.  "css", "scss", etc.)
	 * @param	varName		By default as "STYLE", the public static property fieldname object to add to your class that holds all style classnames. 
	 * 	If left as an empty string, will be de-composed to individual public static inline variables into class.
	 * @return
	 */
	public static  function buildModuleStyleFromFile(?filePath:String, fileExtension:String, varName:String = "STYLE"):Array<Field> {
		var canAutoCreateFile:Bool = false;
		if (filePath == null || filePath == "") {
	
			filePath =  Context.getPosInfos(Context.getLocalClass().get().pos).file;
			var filePathSplit:Array<String> = filePath.split("/");
			var fileName:String = filePathSplit.pop();
			fileName = fileName.split('.')[0];
			filePath = filePathSplit.join("/") +"/"+fileName;
			
			canAutoCreateFile = true;
			
		}
		var tarFile = Sys.getCwd() + filePath + "." + fileExtension;

		var fileExists:Bool =  FileSystem.exists(tarFile);
		var writtenContents:String =fileExists ?  sys.io.File.getContent(tarFile) : "";
		if (!fileExists) {
			if (canAutoCreateFile) {
				File.saveContent( tarFile, writtenContents );
			}
			else {
				Context.error("Failed to find file at:" + tarFile, Context.currentPos() );
			}
		}
		
		return buildModuleStyle(writtenContents, fileExtension, varName);
	}
	
	static var TYPE_STRING = MacroStringTools.toComplex("String");
	
	/**
	 * 
	 * @param	writtenContents
	 * @param	fileExtension	File extension to use (eg.  "css", "scss", etc.)
	 * @param	varName	By default as "STYLE", the public static property fieldname object to add to your class that holds all style classnames.
	 * 	If left as an empty string, will be de-composed to individual public static inline variables into class.
	 * @return
	 */
	public static  function buildModuleStyle(writtenContents:String, fileExtension:String, varName:String="STYLE"):Array<Field> {
		var fileName:String = "_" + Context.getLocalClass().get().module.split(".").join("_");
		
		var workingDirectory:String = Sys.getCwd();
		var cacheDir:String =  workingDirectory + CACHE_FOLDER_NAME+"/";
		var moduleDir:String =  workingDirectory + MODULE_FOLDER_NAME+"/";
		if (!FileSystem.exists(cacheDir)) {
			FileSystem.createDirectory(cacheDir);
		}
		var tarFileCach:String = cacheDir + fileName+"." + fileExtension;
		var tarJSONFileCach:String = moduleDir + fileName+".json";
			
		var cached:Bool = false;
		if ( FileSystem.exists(tarFileCach) && FileSystem.exists(tarJSONFileCach)  ) {
			if (File.getBytes(tarFileCach).compare( Bytes.ofString(writtenContents)  )==0 ) {			
				cached = true;
			}
		}
	
		var theFields = Context.getBuildFields();
		if (!cached) {
			File.saveContent( tarFileCach, writtenContents );
			var src:String = "./" + CACHE_FOLDER_NAME +"/"+fileName+"."+fileExtension;
			var dest:String = "./" + MODULE_FOLDER_NAME;
			var p = new Process('gulp cssmodule --src ${src} --dest ${dest}');
			if (p.exitCode() != 0) {
				Context.warning("Critical warning :: Failed to Process CSS Module Styles!", Context.currentPos() );
				FileSystem.deleteFile(tarFileCach);
				return theFields;
			}
		}
		

		if (varName != "") {
			var expr =  jsonModuleExpr(tarJSONFileCach, fileName);
			theFields.push( {
				name: varName,
				access: [Access.AStatic, Access.APublic],
				kind: FProp("default", "never", TypeTools.toComplexType( Context.typeof(expr) ), expr),
				pos: Context.currentPos(),
			});
		}
		else {
			
			var obj =  jsonModule(tarJSONFileCach, fileName);
			for (f in Reflect.fields(obj) ) {
				var val = Reflect.field(obj, f);
				var expr = macro $v{val};
		
				theFields.push( {
					name: f,
					access: [Access.AStatic, Access.AInline, Access.APublic],
					kind: FVar(TYPE_STRING, expr),
					pos: Context.currentPos(),
				});
			}
		}
		

		return theFields;
	}	
}

#end