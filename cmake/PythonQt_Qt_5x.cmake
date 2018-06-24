find_package(Qt5Core REQUIRED)
find_package(Qt5Widgets REQUIRED)

# aliases
macro(qt_use_modules _target _link_type)
	if(NOT CMAKE_MINIMUM_REQUIRED_VERSION VERSION_LESS 2.8.11)
		if(CMAKE_WARN_DEPRECATED)
			set(messageType WARNING)
		endif()
		if(CMAKE_ERROR_DEPRECATED)
			set(messageType FATAL_ERROR)
		endif()
		if(messageType)
			message(${messageType} "The qt5_use_modules macro is obsolete. Use target_link_libraries with IMPORTED targets instead.")
		endif()
	endif()

	if (NOT TARGET ${_target})
		message(FATAL_ERROR "The first argument to qt5_use_modules must be an existing target.")
	endif()
	if ("${_link_type}" STREQUAL "LINK_PUBLIC" OR "${_link_type}" STREQUAL "LINK_PRIVATE" )
		set(_qt5_modules ${ARGN})
		set(_qt5_link_type ${_link_type})
	else()
		set(_qt5_modules ${_link_type} ${ARGN})
	endif()

	if ("${_qt5_modules}" STREQUAL "")
		message(FATAL_ERROR "qt5_use_modules requires at least one Qt module to use.")
	endif()

	foreach(_module ${_qt5_modules})
		if (NOT Qt5${_module}_FOUND)
			find_package(Qt5${_module} PATHS "${_Qt5_COMPONENT_PATH}" NO_DEFAULT_PATH)
			if (NOT Qt5${_module}_FOUND)
				message(FATAL_ERROR "Can not use \"${_module}\" module which has not yet been found.")
			endif()
		endif()
		target_link_libraries(${_target} ${_qt5_link_type} ${Qt5${_module}_LIBRARIES})
		set_property(TARGET ${_target} APPEND PROPERTY INCLUDE_DIRECTORIES ${Qt5${_module}_INCLUDE_DIRS})
		set_property(TARGET ${_target} APPEND PROPERTY COMPILE_DEFINITIONS ${Qt5${_module}_COMPILE_DEFINITIONS})
		set_property(TARGET ${_target} APPEND PROPERTY COMPILE_DEFINITIONS_RELEASE QT_NO_DEBUG)
		set_property(TARGET ${_target} APPEND PROPERTY COMPILE_DEFINITIONS_RELWITHDEBINFO QT_NO_DEBUG)
		set_property(TARGET ${_target} APPEND PROPERTY COMPILE_DEFINITIONS_MINSIZEREL QT_NO_DEBUG)
		if (Qt5_POSITION_INDEPENDENT_CODE
			AND (CMAKE_VERSION VERSION_LESS 2.8.12
			AND (NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU"
			OR CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.0)))
				set_property(TARGET ${_target} PROPERTY POSITION_INDEPENDENT_CODE ${Qt5_POSITION_INDEPENDENT_CODE})
		endif()
	endforeach()
endmacro()

macro(qt_wrap_cpp)
  qt5_wrap_cpp(${ARGN})
endmacro()

macro(qt_add_resources)
  qt5_add_resources(${ARGN})
endmacro()

# version
set(QT_VERSION_MAJOR ${Qt5Core_VERSION_MAJOR})
set(QT_VERSION_MINOR ${Qt5Core_VERSION_MINOR})
set(QT_VERSION_PATCH ${Qt5Core_VERSION_PATCH})

get_target_property(QtCoreLibraryType Qt5::Core TYPE)
if(${QtCoreLibraryType} MATCHES STATIC_LIBRARY)
	set(QT_STATIC ON)
endif()
